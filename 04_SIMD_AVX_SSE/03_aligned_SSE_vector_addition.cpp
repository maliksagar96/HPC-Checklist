#include <bits/stdc++.h>
#include <xmmintrin.h>  // SSE

using namespace std;

void vector_add_sse_aligned(float* a, float* b, float* c, int n) {

  // process 4 elements per iteration
  for (int i = 0; i <= n - 4; i += 4) {
    __m128 va = _mm_load_ps(&a[i]);   // aligned load
    __m128 vb = _mm_load_ps(&b[i]);

    __m128 vc = _mm_add_ps(va, vb);

    _mm_store_ps(&c[i], vc);          // aligned store
  }

  // remainder
  for (int i = 0; i < n; i++) {
    c[i] = a[i] + b[i];
  }
}

int main() {
  int n = 16; // keep multiple of 4 for simplicity

  // allocate 16-byte aligned memory. aligned_alloc makes sure that the first element of a, b and c is divisible by 16.
  float* a = (float*) aligned_alloc(16, n * sizeof(float));
  float* b = (float*) aligned_alloc(16, n * sizeof(float));
  float* c = (float*) aligned_alloc(16, n * sizeof(float));

  // initialize
  for (int i = 0; i < n; i++) {
    a[i] = i * 1.0f;
    b[i] = 2.0f * i;
  }

  vector_add_sse_aligned(a, b, c, n);
  cout << "Address of First element of a = "<<a<<endl;
  cout << "Address of First element of b = "<<b<<endl;
  cout << "Address of First element of c = "<<b<<endl;
  
  // print
  cout << "Result:\n";
  for (int i = 0; i < n; i++) {
    cout << c[i] << " ";
  }
  cout << endl;

  // free memory
  free(a);
  free(b);
  free(c);

  return 0;
}