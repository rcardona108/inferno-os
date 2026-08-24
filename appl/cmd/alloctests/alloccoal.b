implement Alloccoal;

include "sys.m";
	sys: Sys;
include "draw.m";

Alloccoal: module
{
	init:	fn(nil: ref Draw->Context, nil: list of string);
};

Size: con 1048576;

init(nil: ref Draw->Context, nil: list of string)
{
	a, b, c: array of byte;

	sys = load Sys Sys->PATH;

	sys->print("alloccoal: allocating\n");

	a = array[Size] of byte;
	b = array[Size] of byte;
	c = array[Size] of byte;

	a[0] = byte 17;
	b[0] = byte 34;
	c[0] = byte 51;

	#
	# Free the middle block first.
	#
	b = nil;

	#
	# Free a neighbor.
	# If these heap blocks are physically adjacent,
	# poolfree should now have an opportunity to coalesce.
	#
	a = nil;

	#
	# Free the remaining one.
	#
	c = nil;

	sys->print("alloccoal: complete\n");
}
