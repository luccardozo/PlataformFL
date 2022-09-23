import "hardhat/console.sol";

library DataTypes {
    enum Status { None,
                  WaitingSignatures,
                  WaitingTrainerSignature,
                  WaitingRequesterSignature,
                  Signed,
                  Declined,
                  Fulfilled }

    function StatusToStr(Status status) public pure returns(string memory){
        if (status == Status.WaitingSignatures){
            return "WaitingSignatures";
        }
        if (status == Status.WaitingTrainerSignature){
            return "WaitingTrainerSignature";
        }
        if (status == Status.WaitingRequesterSignature){
            return "WaitingRequesterSignature";
        }
        if (status == Status.Signed){
            return "Signed";
        }
        if (status == Status.Fulfilled){
            return "Fulfilled";
        }
        if (status == Status.Declined){
            return "Declined";
        }
        return "";
    }

    struct Evaluation {
        string comment;
        int rating;
    }

    struct Specification {
        string processor;
        string ram;
        string cpu;        
    }

    struct Offer {
        uint256 ID;
        string description;
        string modelCID;
        uint256 valueByUpdate;
        uint256 numberOfUpdates;        
        address offerMaker;
        address trainer; 
        //Talvez adicionar algum tipo de prazo limit de aceitação.
    }
    
    struct JobRequirements {
        string description;
        uint256 valueByUpdate;   //Valor maximo que o Requisitante está disposto a pagar por update
        uint256 minRating;          //Rating minimo que um candidato deve ter
        string[] tags;          //Tags que devem estar inclusas nas tags dos candidatos
        uint256 canditatesToReturn; //Numero maximo de candindatos a serem retornados. Que serão selecionados manualmente.
    }
}

library Log {
    // FUNÇÕES AUXILIARES
    function Requirement(DataTypes.JobRequirements memory Requirements) view internal {
        console.log("Description =", Requirements.description);
        console.log("CandidatesToReturn =", Requirements.canditatesToReturn);
        console.log("ValueByUpdate =", Requirements.valueByUpdate);
        console.log("MinRating =", Requirements.minRating);
        
        for (uint i=0; i < Requirements.tags.length; i++) {
            console.log("Tag =", Requirements.tags[i], i);
        }
    }

    function Offer(DataTypes.Offer memory offer) public view {
        console.log("ID =", offer.ID);
        console.log("Decription =", offer.description);
        console.log("ModelCID =", offer.modelCID);
        console.log("ValueByUpdate =", offer.valueByUpdate);
        console.log("numberOfUpdates =", offer.numberOfUpdates);
        console.log("OfferMaker =", offer.offerMaker);   
    }
}
