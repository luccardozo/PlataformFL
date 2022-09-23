import "./DataTypes.sol";

contract JobContract {
    string description;
    string modelCID;
    uint256 valueByUpdate;
    uint256 numberOfUpdates;
    uint256 updatesDone;
    uint256 withdrawAmount;

    DataTypes.Status public Status;

    address offerMaker;
    address trainer;
    address DAOManager;

    uint256 lockedAmount;
    uint256 availableAmount;

    modifier onlyDAO {
      require(msg.sender == DAOManager, "Only DAO");
      _;
    }

    constructor(DataTypes.Offer memory offer) {
        DAOManager      = msg.sender;
        offerMaker      = offer.offerMaker;
        trainer         = offer.trainer;
        description     = offer.description;
        valueByUpdate   = offer.valueByUpdate;
        numberOfUpdates = offer.numberOfUpdates;
        updatesDone     = 0;
        lockedAmount    = 0;
        availableAmount = 0;
        withdrawAmount  = 0;
        Status          = DataTypes.Status.WaitingSignatures;

        console.log("JobContract : Trainer = ", trainer, offerMaker);
    }

    function LogContract() public view {
        console.log("JobContract: Decription =", description);
        console.log("JobContract: ModelCID =", modelCID);
        console.log("JobContract: ValueByUpdate =", valueByUpdate);
        console.log("JobContract: numberOfUpdates =", numberOfUpdates);
        console.log("JobContract: updatesDone =", updatesDone);
        console.log("JobContract: lockedAmount =", lockedAmount);
        console.log("JobContract: availableAmount =", availableAmount);
        console.log("JobContract: OfferMaker =", offerMaker);
        console.log("JobContract: trainer =", trainer);
        console.log("JobContract: Status =", DataTypes.StatusToStr(Status)); 
    }

    function totalAmount() public view returns (uint256){
        return (valueByUpdate*numberOfUpdates);
    }

    function lockAmount(uint amount) public onlyDAO {
        lockedAmount = amount;
        console.log("lockAmount =", lockedAmount);    
    }

    function newUpdate() public onlyDAO {
        updatesDone = updatesDone +1;
        availableAmount = availableAmount + valueByUpdate;

        if (updatesDone == numberOfUpdates) {
            Status = DataTypes.Status.Fulfilled;
        }
        console.log("newUpdate =", updatesDone, availableAmount); 
    }

    function withdraw() public onlyDAO returns(uint256){
        uint256 amout  = availableAmount;
        withdrawAmount = withdrawAmount + amout;
        lockedAmount   = lockedAmount - amout;
        
        console.log("withdraw =", amout, withdrawAmount, lockedAmount); 
        return amout;
    }

    function sign(address signer) public onlyDAO {
        console.log("sign: Signer =", signer, trainer, offerMaker);

        require(
            (Status != DataTypes.Status.Signed), "JobContract already signed"
            );

        bool bIsTrainer    = (signer == trainer);
        bool bIsOfferMaker = (signer == offerMaker);

        if (bIsTrainer) {
            if (Status == DataTypes.Status.WaitingSignatures) {
                Status = DataTypes.Status.WaitingRequesterSignature;
            }
            else{
               Status = DataTypes.Status.Signed;
            }
        }

        if (bIsOfferMaker) {
            if (Status == DataTypes.Status.WaitingSignatures) {
                Status = DataTypes.Status.WaitingTrainerSignature;
            }
            else{
               Status = DataTypes.Status.Signed;
            }
        }
    }

    function trainerAddr() public view returns (address){
        return trainer;
    }

    function offerMakerAddr() public view returns (address){
        return offerMaker;
    }
}
