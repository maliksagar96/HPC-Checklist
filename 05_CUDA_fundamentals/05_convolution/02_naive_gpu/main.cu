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

__global__ void process_image(unsigned char *input, unsigned char *output, int Width, int Height) {

	int tid_x = blockDim.x * blockIdx.x + threadIdx.x;
	int tid_y = blockDim.y * blockIdx.y + threadIdx.y;

	if(tid_x > 0 && tid_x < Width - 1 && tid_y > 0 && tid_y < Height - 1) {

		int idx       = tid_y * Width + tid_x;
		int idx_up    = (tid_y - 1) * Width + tid_x;
		int idx_down  = (tid_y + 1) * Width + tid_x;
		int idx_left  = tid_y * Width + (tid_x - 1);
		int idx_right = tid_y * Width + (tid_x + 1);

		output[idx] = (input[idx] + input[idx_up] + input[idx_down] + input[idx_left] + input[idx_right])/5;
	}
}

int main() {

	cout << "Loading the image ...\n";

	cv::Mat img = cv::imread("../input.png", cv::IMREAD_COLOR);

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
	int byteSize = size * sizeof(unsigned char);

	int block = 16;

	dim3 BLOCK(block, block);
	dim3 GRID((Width + block - 1)/block, (Height + block - 1)/block);

	vector<unsigned char> h_r(size), h_r_n(size);
	vector<unsigned char> h_g(size), h_g_n(size);
	vector<unsigned char> h_b(size), h_b_n(size);

	for(int y = 0; y < Height; y++) {
		for(int x = 0; x < Width; x++) {

			cv::Vec3b pixel = img.at<cv::Vec3b>(y, x);

			int idx = y * Width + x;

			h_b[idx] = pixel[0];
			h_g[idx] = pixel[1];
			h_r[idx] = pixel[2];
		}
	}

	unsigned char *d_r, *d_g, *d_b;
	unsigned char *d_r_n, *d_g_n, *d_b_n;

	CUDA_CHECK(cudaMalloc(&d_r, byteSize));
	CUDA_CHECK(cudaMalloc(&d_g, byteSize));
	CUDA_CHECK(cudaMalloc(&d_b, byteSize));

	CUDA_CHECK(cudaMalloc(&d_r_n, byteSize));
	CUDA_CHECK(cudaMalloc(&d_g_n, byteSize));
	CUDA_CHECK(cudaMalloc(&d_b_n, byteSize));

	CUDA_CHECK(cudaMemcpy(d_r, h_r.data(), byteSize, cudaMemcpyHostToDevice));
	CUDA_CHECK(cudaMemcpy(d_g, h_g.data(), byteSize, cudaMemcpyHostToDevice));
	CUDA_CHECK(cudaMemcpy(d_b, h_b.data(), byteSize, cudaMemcpyHostToDevice));

	CUDA_CHECK(cudaMemcpy(d_r_n, d_r, byteSize, cudaMemcpyDeviceToDevice));
	CUDA_CHECK(cudaMemcpy(d_g_n, d_g, byteSize, cudaMemcpyDeviceToDevice));
	CUDA_CHECK(cudaMemcpy(d_b_n, d_b, byteSize, cudaMemcpyDeviceToDevice));

	process_image<<<GRID, BLOCK>>>(d_r, d_r_n, Width, Height);
	process_image<<<GRID, BLOCK>>>(d_g, d_g_n, Width, Height);
	process_image<<<GRID, BLOCK>>>(d_b, d_b_n, Width, Height);

	CUDA_CHECK(cudaGetLastError());
	CUDA_CHECK(cudaDeviceSynchronize());

	CUDA_CHECK(cudaMemcpy(h_r_n.data(), d_r_n, byteSize, cudaMemcpyDeviceToHost));
	CUDA_CHECK(cudaMemcpy(h_g_n.data(), d_g_n, byteSize, cudaMemcpyDeviceToHost));
	CUDA_CHECK(cudaMemcpy(h_b_n.data(), d_b_n, byteSize, cudaMemcpyDeviceToHost));

	cv::Mat output(Height, Width, CV_8UC3);

	for(int y = 0; y < Height; y++) {
		for(int x = 0; x < Width; x++) {

			int idx = y * Width + x;

			output.at<cv::Vec3b>(y, x)[0] = h_b_n[idx];
			output.at<cv::Vec3b>(y, x)[1] = h_g_n[idx];
			output.at<cv::Vec3b>(y, x)[2] = h_r_n[idx];
		}
	}

	cv::imwrite("../output.png", output);

	cudaFree(d_r);	cudaFree(d_g);	cudaFree(d_b);
	cudaFree(d_r_n);	cudaFree(d_g_n);	cudaFree(d_b_n);

	return 0;
}