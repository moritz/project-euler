all: euler_518_v1.exe euler_518_v1-debug.exe

CPPFLAGS = -std=gnu++11

SOURCES = euler_518_v1.cpp primes.txt

euler_518_v1-debug.exe: $(SOURCES)
	g++ $(CPPFLAGS) -g -Wall -o $@ $< -lm

euler_518_v1.exe: $(SOURCES)
	g++ $(CPPFLAGS) -O3 -Wall -flto -fwhole-program -fvisibility=hidden -fomit-frame-pointer -march=native -o $@ $< -lm

primes.txt:
	primes 2 100000000 > $@

clean:
	rm -f *.exe
