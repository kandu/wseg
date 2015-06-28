module Dict :
  sig
    module Tree :
      sig
        type 'a node
      end
    type word= string list * float
    type chunk= word list

    val dispCond : word list -> unit
    val dispCand : chunk list -> unit

    val buildEntries :
      string list -> (string * float) list
    val buildIndex :
       (string * float) list-> float Tree.node
    val candidates :
      float Tree.node -> string -> int -> chunk list
  end

module MMSEG :
  sig
    val rule1 : Dict.chunk list -> Dict.chunk list
    val rule2 : Dict.chunk list -> Dict.chunk list
    val rule3 : Dict.chunk list -> Dict.chunk list
    val rule4 : Dict.chunk list -> Dict.chunk list
    val rule_final : 'a list -> 'a option
    val seg : Dict.chunk list -> Dict.chunk option
  end

module MPSEG : sig  end

