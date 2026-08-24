implement Allocstress;

include "sys.m";
	sys: Sys;
include "draw.m";

Allocstress: module
{
	init:	fn(nil: ref Draw->Context, nil: list of string);
};

Nblock: con 400;
Nlarge: con 24;
Largesize: con 262144;
Refillsize: con 131072;

fill(a: array of byte, v: byte)
{
	i: int;

	for(i = 0; i < len a; i++)
		a[i] = v;
}

check(a: array of byte, v: byte): int
{
	i: int;

	for(i = 0; i < len a; i++)
		if(a[i] != v)
			return 0;

	return 1;
}

init(nil: ref Draw->Context, nil: list of string)
{
	block: array of array of byte;
	large: array of array of byte;
	i: int;
	size: int;
	v: byte;

	sys = load Sys Sys->PATH;

	sys->print("allocstress: starting\n");

	block = array[Nblock] of array of byte;

	for(i = 0; i < Nblock; i++) {
		size = 64 + (i % 16) * 257;
		block[i] = array[size] of byte;

		v = byte ((i % 200) + 1);
		fill(block[i], v);
	}

	for(i = 0; i < Nblock; i++) {
		v = byte ((i % 200) + 1);

		if(check(block[i], v) == 0) {
			sys->print("FAIL: initial block %d corrupted\n", i);
			return;
		}
	}

	sys->print("PASS: mixed allocations\n");

	for(i = 0; i < Nblock; i = i + 2)
		block[i] = nil;

	for(i = 0; i < Nblock; i = i + 2) {
		size = 96 + (i % 13) * 311;
		block[i] = array[size] of byte;

		v = byte (((i + 50) % 200) + 1);
		fill(block[i], v);
	}

	for(i = 0; i < Nblock; i++) {
		if((i % 2) == 0)
			v = byte (((i + 50) % 200) + 1);
		else
			v = byte ((i % 200) + 1);

		if(check(block[i], v) == 0) {
			sys->print("FAIL: reused block %d corrupted\n", i);
			return;
		}
	}

	sys->print("PASS: fragmentation/reuse\n");

	large = array[Nlarge] of array of byte;

	for(i = 0; i < Nlarge; i++) {
		large[i] = array[Largesize] of byte;
		large[i][0] = byte (i + 1);
		large[i][Largesize - 1] = byte (i + 101);
	}

	for(i = 0; i < Nlarge; i++) {
		if(large[i][0] != byte (i + 1) ||
		   large[i][Largesize - 1] != byte (i + 101)) {
			sys->print("FAIL: large block %d corrupted\n", i);
			return;
		}
	}

	sys->print("PASS: large allocations\n");

	for(i = 0; i < Nlarge; i = i + 2)
		large[i] = nil;

	for(i = 0; i < Nlarge; i = i + 2) {
		large[i] = array[Refillsize] of byte;
		large[i][0] = byte (i + 2);
		large[i][Refillsize - 1] = byte (i + 102);
	}

	for(i = 0; i < Nlarge; i++) {
		if((i % 2) == 0) {
			if(large[i][0] != byte (i + 2) ||
			   large[i][Refillsize - 1] != byte (i + 102)) {
				sys->print("FAIL: replacement block %d corrupted\n", i);
				return;
			}
		}
		else {
			if(large[i][0] != byte (i + 1) ||
			   large[i][Largesize - 1] != byte (i + 101)) {
				sys->print("FAIL: surviving block %d corrupted\n", i);
				return;
			}
		}
	}

	sys->print("PASS: large block reuse\n");

	for(i = 0; i < Nblock; i++)
		block[i] = nil;

	for(i = 0; i < Nlarge; i++)
		large[i] = nil;

	sys->print("PASS: allocstress complete\n");
}
