#include <bits/stdc++.h>
#include <xmmintrin.h>  // SSE

using namespace std;

void vector_add_sse(float* a, float* b, float* c, int n) {
  
  // process 4 elements per iteration
  for (int i = 0; i <= n - 4; i += 4) {
    //128 bits. An integer or float is 32 bits. That's why it can add 4 integers at a time. 
    //Loadu meaning this is unaligned. ps means packed single precision. 
    __m128 va = _mm_loadu_ps(&a[i]);
    __m128 vb = _mm_loadu_ps(&b[i]);

    __m128 vc = _mm_add_ps(va, vb);

    _mm_storeu_ps(&c[i], vc);
  }

  // remainder
  for (; i < n; i++) {
    c[i] = a[i] + b[i];
  }
}

int main() {
  int n = 12;

  vector<float> a(n), b(n), c(n);

  // initialize
  for (int i = 0; i < n; i++) {
    a[i] = i * 1.0f;
    b[i] = 2.0f * i;
  }

  // call SIMD function
  vector_add_sse(a.data(), b.data(), c.data(), n);
  cout <<"Inputs:\n";
  for(int i = 0;i<n;i++) {
      cout << a[i] << " ";
  }
    
  cout << endl;
  
  for(int i = 0;i<n;i++) {
      cout << b[i] << " ";
  }

  cout << endl;
  // print result
  cout << "Result:\n";
  for (int i = 0; i < n; i++) {
    cout << c[i] << " ";
  }
  cout << endl;

  return 0;
}