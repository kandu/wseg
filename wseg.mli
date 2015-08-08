module Dict :
  sig
    module Tree :
      sig
        type 'a node
      end

    type entry= string * float
    type entries= entry list

    type word= string list * float
    type chunk= word list

    val dispConds : word list -> unit
    val dispCands : chunk list -> unit
    val result_of_cand : chunk -> string

    val buildEntries : entries -> entries
    val buildIndex : entries-> float Tree.node
    val candidates : float Tree.node -> string -> int -> chunk list
  end

module MMSEG :
  sig
    val rule1 : Dict.chunk list -> Dict.chunk list
    val rule2 : Dict.chunk list -> Dict.chunk list
    val rule3 : Dict.chunk list -> Dict.chunk list
    val rule4 : Dict.chunk list -> Dict.chunk list
    val rule_final : Dict.chunk list -> Dict.chunk option
    val seg : Dict.chunk list -> Dict.chunk option
  end

