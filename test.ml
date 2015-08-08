open Core_kernel.Std
open Fn
open Wseg

let test dict max str=
  let cand= Dict.candidates dict str max in
  begin
    printf "candidates of %s\n" str;
    cand |> Dict.dispCands;
    let cand1= cand |> MMSEG.rule1 in
    printf "rule1\n";
    Dict.dispCands cand1;
    let cand2= cand1 |> MMSEG.rule2 in
    printf "rule2\n";
    Dict.dispCands cand2;
    let cand3= cand2 |> MMSEG.rule3 in
    printf "rule3\n";
    Dict.dispCands cand3;
    let cand4= cand3 |> MMSEG.rule4 in
    printf "rule4\n";
    Dict.dispCands cand4;
    match MMSEG.rule_final cand4 with
    | Some chunk-> printf "result: [%s]\n" (Dict.result_of_cand chunk)
    | None-> ()
  end

let ()=
  let charEntries=
    Dict.buildEntries (In_channel.read_lines "char.dic")
  and wordEntries=
    Dict.buildEntries (In_channel.read_lines "word.dic")
  in
  let wordDict= Dict.buildIndex (List.append charEntries wordEntries) in
  test wordDict 4 "研究生命起源";
  test wordDict 4 "主要是因为"

