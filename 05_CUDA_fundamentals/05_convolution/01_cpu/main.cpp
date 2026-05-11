#include <iostream>
#include <vector>
#include <opencv2/opencv.hpp>

using namespace std;

void blurFilter(vector<unsigned char>& h_r, vector<unsigned char>& h_g, vector<unsigned char>& h_b, vector<unsigned char>& h_r_n, vector<unsigned char>& h_g_n, vector<unsigned char>& h_b_n, int Height, int Width) {

	h_r_n = h_r;
	h_b_n = h_b;
	h_g_n = h_g;

	for(int h = 1; h < Height - 1; h++) {
		for(int w = 1; w < Width - 1; w++) {

			int current = h * Width + w;
			int left = h * Width + (w - 1);
			int right = h * Width + (w + 1);
			int top = (h - 1) * Width + w;
			int bottom = (h + 1) * Width + w;

			h_r_n[current] = (h_r[left] + h_r[right] + h_r[current] + h_r[top] + h_r[bottom]) / 5;
			h_g_n[current] = (h_g[left] + h_g[right] + h_g[current] + h_g[top] + h_g[bottom]) / 5;
			h_b_n[current] = (h_b[left] + h_b[right] + h_b[current] + h_b[top] + h_b[bottom]) / 5;
		}
	}
}

int main() {

	cout << "Loading the image ...\n";

	cv::Mat img = cv::imread("../output	.png");

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

	blurFilter(h_r, h_g, h_b, h_r_n, h_g_n, h_b_n, Height, Width);

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

	return 0;
}