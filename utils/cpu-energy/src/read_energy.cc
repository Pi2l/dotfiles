#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <time.h>
#include <fstream>
#include <sys/stat.h>
#include <unistd.h>


static const char* STATE_DIR       = "/tmp/read-e";
static const char* ENERGY_FILE     = "/tmp/read-e/energy_uj";
static const char* TIMESTAMP_FILE  = "/tmp/read-e/timestamp_us";

static void ensure_state_dir()
{
  struct stat st;
  if (stat(STATE_DIR, &st) != 0) {
    mkdir(STATE_DIR, 0755);
  }
}

static bool read_ll_from_file(const char* path, long long& value)
{
  std::ifstream file(path);
  if (!file.good())
    return false;

  file >> value;
  return file.good();
}

static void write_ll_to_file(const char* path, long long value)
{
  std::ofstream file(path, std::ios::trunc);
  file << value;
}

long long get_monotonicTimeUSec()
{
	struct timespec time;
	clock_gettime(CLOCK_MONOTONIC, &time);
	return time.tv_sec * 1000000 + time.tv_nsec / 1000;
}

long long get_cpuConsumptionUJoules()
{
  long long consumption = -1;
  const auto rapl_power_usage_path = "/sys/class/powercap/intel-rapl:0/energy_uj";
  std::ifstream file(rapl_power_usage_path);
  if(file.good())
  {
    std::cerr << "file good = " << consumption << std::endl;
    file >> consumption;
  }
  std::cerr << "consumption = " << consumption << std::endl;
  return consumption;
}

float get_cpuConsumptionWatts()
{
  static long long previous_usage = 0;
  static long long previous_timestamp = 0;
  ensure_state_dir();

  bool have_prev_usage =
    read_ll_from_file(ENERGY_FILE, previous_usage);
  bool have_prev_timestamp =
    read_ll_from_file(TIMESTAMP_FILE, previous_timestamp);

  long long current_usage = get_cpuConsumptionUJoules();
  long long current_timestamp = get_monotonicTimeUSec();

  // If RAPL not supported
  if (current_usage <= 0) {
    std::cout << "rapl not supported" << std::endl;
    return -1;
  }

  // First-ever run (no state yet)
  // if (!have_prev_usage || !have_prev_timestamp) {
  //   std::cout << "first run: " << have_prev_usage << " have_prev_timestamp: " << have_prev_timestamp << std::endl;
  //   write_ll_to_file(ENERGY_FILE, current_usage);
  //   write_ll_to_file(TIMESTAMP_FILE, current_timestamp);
  //   return 0;
  // }

  long long du = current_usage - previous_usage;
  long long dt = current_timestamp - previous_timestamp;
  std::cerr << "du = " << du << " dt = " << dt << std::endl;
  // Protect against clock or counter issues
  if (du < 0 || dt <= 0) {
    write_ll_to_file(ENERGY_FILE, current_usage);
    write_ll_to_file(TIMESTAMP_FILE, current_timestamp);
    return 0;
  }

  float watts = (float)du / (float)dt;

  write_ll_to_file(ENERGY_FILE, current_usage);
  write_ll_to_file(TIMESTAMP_FILE, current_timestamp);

  return watts;
}
