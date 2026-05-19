#include <vtkSmartPointer.h>
#include <vtkSTLReader.h>
#include <vtkPolyData.h>
#include <iostream>

using namespace std;

int main() {
  vtkSmartPointer<vtkSTLReader> reader = vtkSmartPointer<vtkSTLReader>::New();

  reader->SetFileName("../cube.stl");
  reader->Update();

  vtkPolyData* data = reader->GetOutput();
  std::cout << "Number of points: "<< data->GetNumberOfPoints() << std::endl;
  std::cout << "Number of cells: "<< data->GetNumberOfCells() << std::endl;

  return 0;
}