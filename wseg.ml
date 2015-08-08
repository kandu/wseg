open Core_kernel.Std
open Fn

module Dict = struct
  module Tree = Trie.Make(String)

  type entry= string * float
  type entries= entry list

  let split_utf8 ?(pos=0) s=
    let len= String.length s in
    let rec to_list pos=
      if pos >= len then
        []
      else
        let next= CamomileLibrary.UTF8.next s pos in
        if next > len then
          []
        else
          String.sub s pos (next - pos) :: (to_list next)
    in
    to_list pos

  let rex= Pcre.regexp "^([^\t]+)\t([^\t]+)"

  let get_entry s=
    let ss= Pcre.exec ~rex s |> Pcre.get_substrings in
    (ss.(1), Float.of_string ss.(2))

  let buildEntries rawEntries=
    let entries= List.map rawEntries ~f:get_entry in
    let quantity= List.fold entries
      ~init:0.
      ~f:(fun acc (char, count)-> acc +. count)
    in
    List.map entries ~f:(fun (char, count)-> (char, count /. quantity))

  let buildIndex entries=
    let tree= Tree.create None in
    List.iter entries ~f:(fun (token, freq)->
      Tree.set tree (split_utf8 token) freq);
    tree

  type word= string list * float
  type chunk= word list

  let dispCond cd=
    List.iter cd ~f:(fun (cl, freq)->
      List.iter cl ~f:(printf "%s ");
      print_newline ());
    print_newline ()

  let dispCand cd=
    List.iter cd ~f:(fun (wl:word list)->
      List.iter wl ~f:(fun (cl, freq)->
        List.iter cl ~f:print_string; print_string " ");
        print_newline ());
    print_newline ()

  let condWord node s=
    let rec condWord node cl pos= match cl with
    | []-> []
    | c::tl-> match Tree.sub node [c] with
      | None-> []
      | Some node-> match Tree.get node [] with
        | None-> condWord node tl (pos+1)
        | Some freq-> ((List.split_n s (pos+1) |> Tuple2.get1), freq)
          :: (condWord node tl (pos+1))
    in
    condWord node s 0

  let candidates wordDict s max=
    let rec candidates s max=
      if max > 0 && List.length s > 0 then
        let words= condWord wordDict s in
        List.map words ~f:(fun word->
          let (cl, freq)= word in
          let suffix= candidates
            (List.split_n s (List.length cl) |> Tuple2.get2)
            (max-1) in
          match suffix with
          | []-> [[word]]
          | _-> List.map suffix ~f:(fun suffix-> word::suffix))
        |> List.join
      else []
    in
    candidates (split_utf8 s) max
end

let length_word (sl, _)= List.fold sl
  ~init:0
  ~f:(fun acc s-> acc + String.length s)

let length_chunk chunk= List.fold chunk
  ~init:0
  ~f:(fun acc word-> acc + length_word word)

let average chunk= (/.)
  (List.fold chunk
    ~init:0
    ~f:(fun acc word-> acc + length_word word)
    |> Float.of_int)
  (List.length chunk |> Float.of_int)

let possibility_mul chunk= List.fold chunk
  ~init:1.
  ~f:(fun acc (_, freq)-> acc *. freq)

let variance chunk=
  let avg= average chunk in
  (/.)
    (List.fold chunk
      ~init:0.
      ~f:(fun acc word-> acc +. (Float.of_int (length_word word) -. avg) ** 2.))
    (List.length chunk |> Float.of_int)

module MMSEG = struct
  let rule1 chunks=
    let (len, res)=
      List.fold chunks ~init:(0, []) ~f:(fun (len, res) chunk->
        let len_curr = length_chunk chunk in
        if len_curr = len then
          (len, chunk::res)
        else
          if len_curr > len then
            (len_curr, [chunk])
          else
            (len, res)
        )
    in
    List.rev res

  let rule2 chunks=
    let (avg, res)=
      List.fold chunks ~init:(0., []) ~f:(fun (avg, res) chunk->
        let avg_curr = average chunk in
        if avg_curr = avg then
          (avg, chunk::res)
        else
          if avg_curr > avg then
            (avg_curr, [chunk])
          else
            (avg, res)
        )
    in
    List.rev res

  let rule3 chunks=
    let (vari, res)=
      List.fold chunks ~init:(Float.infinity, []) ~f:(fun (vari, res) chunk->
        let vari_curr = variance chunk in
        if vari_curr = vari then
          (vari, chunk::res)
        else
          if vari_curr < vari then
            (vari_curr, [chunk])
          else
            (vari, res)
        )
    in
    List.rev res

  let rule4 chunks=
    let (possibility, res)=
      List.fold chunks ~init:(0., []) ~f:(fun (possibility, res) chunk->
        let possibility_curr = possibility_mul chunk in
        if possibility_curr = possibility then
          (possibility, chunk::res)
        else
          if possibility_curr > possibility then
            (possibility_curr, [chunk])
          else
            (possibility, res)
        )
    in
    List.rev res

  let rule_final= List.hd

  let seg chunks= chunks |> rule1 |> rule2 |> rule3 |> rule4 |> rule_final
end

module MPSEG = struct
end

