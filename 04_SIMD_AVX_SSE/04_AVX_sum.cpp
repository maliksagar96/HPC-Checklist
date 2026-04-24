#include <bits/stdc++.h>
#include <immintrin.h>  // AVX

using namespace std;

void vector_add_avx(float* a, float* b, float* c, int n) {
  
  // process 8 elements per iteration
  for (int i = 0; i <= n - 8; i += 8) {
    __m256 va = _mm256_load_ps(&a[i]);   // aligned load (32 bytes)
    __m256 vb = _mm256_load_ps(&b[i]);

    __m256 vc = _mm256_add_ps(va, vb);   // SIMD add

    _mm256_store_ps(&c[i], vc);          // aligned store
  }

  // remainder
  for (int i = 0; i < n; i++) {
    c[i] = a[i] + b[i];
  }
}

int main() {
  int n = 16; // multiple of 8

  // 32-byte aligned allocation (required for AVX)
  float* a = (float*) aligned_alloc(32, n * sizeof(float));
  float* b = (float*) aligned_alloc(32, n * sizeof(float));
  float* c = (float*) aligned_alloc(32, n * sizeof(float));

  // initialize
  for (int i = 0; i < n; i++) {
    a[i] = i * 1.0f;
    b[i] = 2.0f * i;
  }

  vector_add_avx(a, b, c, n);

  cout << "Address of a = " << a << endl;
  cout << "Address of b = " << b << endl;
  cout << "Address of c = " << c << endl;

  cout << "Result:\n";
  for (int i = 0; i < n; i++) {
    cout << c[i] << " ";
  }
  cout << endl;

  free(a);
  free(b);
  free(c);

  return 0;
}