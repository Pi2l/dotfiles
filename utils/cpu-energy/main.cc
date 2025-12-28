#include "src/read_energy.hpp"
#include <stdio.h>
#include <iostream>

int main (int argc, char *argv[]) {
  std::cout << get_cpuConsumptionWatts() << std::endl; // in Watts
  return 0;
}
