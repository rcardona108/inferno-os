implement Allocbasic;

include "sys.m";
	sys: Sys;
include "draw.m";

Allocbasic: module
{
	init:	fn(nil: ref Draw->Context, nil: list of string);
};

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
	a, b, c, d: array of byte;

	sys = load Sys Sys->PATH;

	sys->print("allocbasic: starting\n");

	# Different allocation sizes.
	a = array[1] of byte;
	b = array[128] of byte;
	c = array[4096] of byte;
	d = array[65536] of byte;

	fill(a, byte 17);
	fill(b, byte 34);
	fill(c, byte 51);
	fill(d, byte 68);

	if(check(a, byte 17) == 0) {
		sys->print("FAIL: a corrupted\n");
		return;
	}

	if(check(b, byte 34) == 0) {
		sys->print("FAIL: b corrupted\n");
		return;
	}

	if(check(c, byte 51) == 0) {
		sys->print("FAIL: c corrupted\n");
		return;
	}

	if(check(d, byte 68) == 0) {
		sys->print("FAIL: d corrupted\n");
		return;
	}

	sys->print("PASS: initial allocations\n");

	# Release b, then allocate another object of the same size.
	b = nil;
	b = array[128] of byte;
	fill(b, byte 85);

	# Make sure the new allocation did not corrupt
	# any of the still-live allocations.
	if(check(a, byte 17) == 0) {
		sys->print("FAIL: a corrupted after reuse\n");
		return;
	}

	if(check(b, byte 85) == 0) {
		sys->print("FAIL: new b corrupted\n");
		return;
	}

	if(check(c, byte 51) == 0) {
		sys->print("FAIL: c corrupted after reuse\n");
		return;
	}

	if(check(d, byte 68) == 0) {
		sys->print("FAIL: d corrupted after reuse\n");
		return;
	}

	sys->print("PASS: free/reallocate\n");

	a = nil;
	b = nil;
	c = nil;
	d = nil;

	sys->print("PASS: allocbasic complete\n");
}
