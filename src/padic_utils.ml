(** p-adic distance and filtering utilities - optimized for Raspberry Pi Zero W *)

type request_info = {
  id: int;
  path: string;
  deps: int list;
  priority: int; (* Low-memory priority system *)
}

(** Memory-efficient p-adic distance calculation *)
let p_adic_distance p x y =
  let diff = abs (x - y) in
  if diff = 0 then 0.0 else
    (* Optimized valuation for ARM - avoid heavy float operations *)
    let rec valuation p n acc =
      if n mod p = 0 && acc < 10 then (* Limit depth for Pi Zero *)
        valuation p (n / p) (acc + 1) 
      else acc
    in 
    (* Use lookup table for small powers to reduce computation *)
    let power_table = [|1.0; 0.5; 0.25; 0.125; 0.0625; 0.03125|] in
    let val_result = valuation p diff 0 in
    if val_result < 6 then power_table.(val_result)
    else 1.0 /. (float_of_int p ** float_of_int val_result)

(** Memory-conscious request filtering *)
let filter_requests threshold p requests =
  (* Process in chunks to avoid memory spikes on Pi Zero *)
  let chunk_size = 100 in
  let rec process_chunks acc = function
    | [] -> acc
    | chunk ->
        let (current_chunk, rest) = 
          if List.length chunk > chunk_size then
            (List.take chunk_size chunk, List.drop chunk_size chunk)
          else (chunk, [])
        in
        let filtered_chunk = List.filter (fun req -> 
          List.for_all (fun dep -> 
            p_adic_distance p req.id dep <= threshold
          ) req.deps
        ) current_chunk in
        process_chunks (filtered_chunk @ acc) rest
  in
  process_chunks [] requests

(** Cache-friendly radix sort for ARM *)
let radix_sort_digit lst pos base =
  (* Use smaller buckets to fit in L1 cache *)
  let max_buckets = min base 16 in
  let buckets = Array.make max_buckets [] in
  List.iter (fun x -> 
    let digit = (x.id / (int_of_float (float_of_int base ** float_of_int (pos-1)))) mod max_buckets in
    buckets.(digit) <- x :: buckets.(digit)
  ) lst;
  Array.fold_left (fun acc bucket -> bucket @ acc) [] (Array.to_list buckets)

let radix_sort lst max_digits base =
  (* Limit digits for Pi Zero performance *)
  let safe_digits = min max_digits 4 in
  let safe_base = min base 16 in
  let rec sort_at_position pos acc =
    if pos = 0 then acc else
      sort_at_position (pos-1) (radix_sort_digit acc pos safe_base)
  in 
  sort_at_position safe_digits lst

(** Lightweight request priority calculation *)
let calculate_priority req =
  (* Simple heuristic based on path and dependencies *)
  let path_weight = String.length req.path mod 8 in
  let dep_weight = List.length req.deps in
  (path_weight + dep_weight) mod 16
