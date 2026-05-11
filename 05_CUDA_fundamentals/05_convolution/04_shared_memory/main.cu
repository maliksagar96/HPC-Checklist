/*

| Metric                                              | Meaning                                             |
| --------------------------------------------------- | --------------------------------------------------- |
| `gpu__time_duration.sum`                            | Total kernel execution time on GPU                  |
| `dram__bytes_read.sum`                              | Total bytes read from DRAM/global memory            |
| `dram__bytes_write.sum`                             | Total bytes written to DRAM/global memory           |
| `l1tex__t_bytes_pipe_lsu_mem_global_op_ld.sum`      | Bytes loaded from global memory through L1/TEX path |
| `l1tex__t_bytes_pipe_lsu_mem_global_op_st.sum`      | Bytes stored to global memory through L1/TEX path   |
| `sm__warps_active.avg.pct_of_peak_sustained_active` | Average SM occupancy percentage                     |
| `smsp__inst_executed.sum`                           | Total instructions executed by SM sub-partitions    |

To check all the metrics.

ncu --metrics gpu__time_duration.sum,dram__bytes_read.sum,dram__bytes_write.sum,l1tex__t_bytes_pipe_lsu_mem_global_op_ld.sum,l1tex__t_bytes_pipe_lsu_mem_global_op_st.sum,sm__warps_active.avg.pct_of_peak_sustained_active,smsp__inst_executed.sum ./main
*/

#include <iostream>
#include <vector>
#include <cuda_runtime.h>
#include <opencv2/opencv.hpp>

using namespace std;

#define CUDA_CHECK(call)                                                   \
do {                                                                       \
  cudaError_t err = call;                                                  \
  if(err != cudaSuccess) {                                                 \
    cerr << "CUDA Error: " << cudaGetErrorString(err)                      \
         << " at line " << __LINE__ << endl;                               \
    exit(EXIT_FAILURE);                                                    \
  }                                                                        \
} while(0)

#define BLOCK_SIZE 16

__global__ void process_image(uchar3 *input, uchar3 *output, int Width, int Height) {

	__shared__ uchar3 shmem[BLOCK_SIZE + 2][BLOCK_SIZE + 2];

	int tid_x = blockDim.x * blockIdx.x + threadIdx.x;
	int tid_y = blockDim.y * blockIdx.y + threadIdx.y;

	int local_x = threadIdx.x + 1;
	int local_y = threadIdx.y + 1;

	int idx = tid_y * Width + tid_x;

	//Loading center pixels
	if(tid_x < Width && tid_y < Height)
		shmem[local_y][local_x] = input[idx];

	//Loading left halo
	if(threadIdx.x == 0 && tid_x > 0 && tid_y < Height)
		shmem[local_y][0] = input[tid_y * Width + (tid_x - 1)];

	//Loading right halo
	if(threadIdx.x == BLOCK_SIZE - 1 && tid_x < Width - 1 && tid_y < Height)
		shmem[local_y][BLOCK_SIZE + 1] = input[tid_y * Width + (tid_x + 1)];

	//Loading top halo
	if(threadIdx.y == 0 && tid_y > 0 && tid_x < Width)
		shmem[0][local_x] = input[(tid_y - 1) * Width + tid_x];

	//Loading bottom halo
	if(threadIdx.y == BLOCK_SIZE - 1 && tid_y < Height - 1 && tid_x < Width)
		shmem[BLOCK_SIZE + 1][local_x] = input[(tid_y + 1) * Width + tid_x];

	__syncthreads();

	//Stencil operation from shared memory
	if(tid_x > 0 && tid_x < Width - 1 && tid_y > 0 && tid_y < Height - 1) {
		output[idx].x = (shmem[local_y][local_x].x + shmem[local_y - 1][local_x].x + shmem[local_y + 1][local_x].x + shmem[local_y][local_x - 1].x + shmem[local_y][local_x + 1].x)/5;
		output[idx].y = (shmem[local_y][local_x].y +shmem[local_y - 1][local_x].y + shmem[local_y + 1][local_x].y + shmem[local_y][local_x - 1].y +	shmem[local_y][local_x + 1].y)/5;
		output[idx].z = (shmem[local_y][local_x].z + shmem[local_y - 1][local_x].z + shmem[local_y + 1][local_x].z + shmem[local_y][local_x - 1].z + shmem[local_y][local_x + 1].z)/5;
	}
}

int main() {

	cout << "Loading the image ...\n";

	cv::Mat img = cv::imread("../output.png", cv::IMREAD_COLOR);

	if(img.empty()) {
		cout << "Image not loaded\n";
		return 1;
	}

	cout << "Image loaded.\n";

	int Width = img.cols;
	int Height = img.rows;

	cout << "Width  : " << Width << '\n';
	cout << "Height : " << Height << '\n';

	int size = Width * Height;
	int byteSize = size * sizeof(uchar3);

	dim3 BLOCK(BLOCK_SIZE, BLOCK_SIZE);
	dim3 GRID((Width + BLOCK_SIZE - 1)/BLOCK_SIZE, (Height + BLOCK_SIZE - 1)/BLOCK_SIZE);

	vector<uchar3> h_input(size), h_output(size);

	for(int y = 0; y < Height; y++) {
		for(int x = 0; x < Width; x++) {

			int idx = y * Width + x;

			cv::Vec3b pixel = img.at<cv::Vec3b>(y, x);

			h_input[idx].x = pixel[0];
			h_input[idx].y = pixel[1];
			h_input[idx].z = pixel[2];
		}
	}

	uchar3 *d_input, *d_output;

	CUDA_CHECK(cudaMalloc(&d_input, byteSize));
	CUDA_CHECK(cudaMalloc(&d_output, byteSize));

	CUDA_CHECK(cudaMemcpy(d_input, h_input.data(), byteSize, cudaMemcpyHostToDevice));
	CUDA_CHECK(cudaMemcpy(d_output, d_input, byteSize, cudaMemcpyDeviceToDevice));

	process_image<<<GRID, BLOCK>>>(d_input, d_output, Width, Height);

	CUDA_CHECK(cudaGetLastError());
	CUDA_CHECK(cudaDeviceSynchronize());

	CUDA_CHECK(cudaMemcpy(h_output.data(), d_output, byteSize, cudaMemcpyDeviceToHost));

	cv::Mat output(Height, Width, CV_8UC3);

	for(int y = 0; y < Height; y++) {
		for(int x = 0; x < Width; x++) {

			int idx = y * Width + x;

			output.at<cv::Vec3b>(y, x)[0] = h_output[idx].x;
			output.at<cv::Vec3b>(y, x)[1] = h_output[idx].y;
			output.at<cv::Vec3b>(y, x)[2] = h_output[idx].z;
		}
	}

	cv::imwrite("../output2.png", output);

	cudaFree(d_input);
	cudaFree(d_output);

	return 0;
}