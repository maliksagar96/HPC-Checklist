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

__global__ void process_image(uchar3 *input, uchar3 *output, int Width, int Height) {

	int tid_x = blockDim.x * blockIdx.x + threadIdx.x;
	int tid_y = blockDim.y * blockIdx.y + threadIdx.y;

	if(tid_x > 0 && tid_x < Width - 1 && tid_y > 0 && tid_y < Height - 1) {

		int idx       = tid_y * Width + tid_x;
		int idx_up    = (tid_y - 1) * Width + tid_x;
		int idx_down  = (tid_y + 1) * Width + tid_x;
		int idx_left  = tid_y * Width + (tid_x - 1);
		int idx_right = tid_y * Width + (tid_x + 1);

		output[idx].x = (input[idx].x + input[idx_up].x + input[idx_down].x + input[idx_left].x + input[idx_right].x)/5;
		output[idx].y = (input[idx].y + input[idx_up].y + input[idx_down].y + input[idx_left].y + input[idx_right].y)/5;
		output[idx].z = (input[idx].z + input[idx_up].z + input[idx_down].z + input[idx_left].z + input[idx_right].z)/5;
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

	int block = 16;

	dim3 BLOCK(block, block);
	dim3 GRID((Width + block - 1)/block, (Height + block - 1)/block);

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