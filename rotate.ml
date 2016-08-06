type free_elem = [ A | A1 | B | B1 ].

value rotate_param (a, b, c, n) e =
  match e with
  | A -> (3 * a, b + 2 * c, - 4 * b + c, n + 1)
  | A1 -> (3 * a, b - 2 * c, 4 * b + c, n + 1)
  | B -> (a + 4 * b, - 2 * a + b, 3 * c, n + 1)
  | B1 -> (a - 4 * b, 2 * a + b, 3 * c, n + 1)
  end.

value rotate_1_0_0_param el = List.fold_left rotate_param (1, 0, 0, 0) el.

value rotate_1_0_0 el =
  let (a, b, c, n) = rotate_1_0_0_param el in
  let d = 3.0 ** float n in
  (float a /. d, float b *. sqrt 2.0 /. d, float c /. d).
