
def wide_to_long(foo: int, bar: bool, *, baz) -> None:
    """Wide to long demo function."""
    print(foo, bar, baz)


wide_to_long(
    foo=1,
    bar=False,
    baz='a',
)
