import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "hardhat/console.sol";

import "./DataTypes.sol";
import "./Requester.sol";
import "./Trainer.sol";
import "./JobContract.sol";


contract DAO {
    // Add the library methods
    using Counters for Counters.Counter;

    //Treinadores
    mapping(address => address) trainers;
    address[] public registeredTrainers;

    //Requisitantes
    mapping(address => address) requesters;
    address[] public registeredRequesters;

    //jobContracts Contrats
    mapping(address => JobContract) jobContracts;

    Counters.Counter UID;

    function nextID() private returns(uint256) {
       uint256 ID = UID.current();
       UID.increment();

       return ID;

    } 

    // Trainer
    function registerTrainer (string memory _description, DataTypes.Specification memory _specification ) external returns(address){
        require(
            !isTrainer(msg.sender), "Trainer already registered"
        );
        console.log("registerTrainer: ", msg.sender);

        Trainer newTrainer = new Trainer(msg.sender, _description, _specification);      

        //guarda o treinador na hash
        trainers[msg.sender] =  address(newTrainer);
        registeredTrainers.push(msg.sender);

        console.log("registerTrainer: End ", msg.sender, " TrainersCount=", registeredTrainers.length);

        return address(newTrainer);
    }

    //Requester
    function registerRequester ( ) external returns(address){
        require(
            !isRequester(msg.sender), "Requester already registered"
        );
        console.log("registerRequester: ", msg.sender);
        
        Requester newRequester = new Requester(msg.sender);

        //guarda o requisitante na hash
        requesters[msg.sender] =  address(newRequester);
        registeredRequesters.push(msg.sender);
        
        console.log("registerRequester: End", msg.sender,"RequestersCount=", registeredRequesters.length);

        return address(newRequester);
    }
    
    function matchTrainers (DataTypes.JobRequirements memory Requirements) external view returns(address  [] memory) {
        address [] memory candidates = new address[](Requirements.canditatesToReturn);
        uint256 candidatesCount = 0;
        uint256 i = 0;

        Log.Requirement(Requirements);

        while ((candidatesCount < Requirements.canditatesToReturn) && (i < registeredTrainers.length)) {
            address trainerAddr = registeredTrainers[i];      
                
            Trainer trainer = Trainer(trainers[trainerAddr]);

            //Ve se da match entre o treinador e a oferta
            if (isMatch(Requirements, trainer)) {
                console.log("requestTrainer: MATCH ", trainerAddr, i);
                candidates[i] = trainerAddr;
                candidatesCount = candidatesCount + 1;
            }
            else{
                console.log("requestTrainer: NOT match ", trainerAddr, i);
            }

            //Continua iteração
            i = i + 1;            
        }

        return candidates;
    }

    function isMatch(DataTypes.JobRequirements memory Requirements, Trainer trainer) internal pure returns (bool){
        return true;
    }

    function MakeOffer(string memory description, string memory modelCID, uint256 valueByUpdate, uint256 numberOfUpdates, address trainerAddr) external {
        require(
            isRequester(msg.sender), "Requester not registered"
        );
        require(
            isTrainer(trainerAddr), "Trainer not found"
        );
        console.log("MakeOffer: ");
    
        Trainer trainer = Trainer(trainers[trainerAddr]);

        DataTypes.Offer memory offer;
        offer.ID              = nextID();
        offer.description     = description;
        offer.modelCID        = modelCID;
        offer.valueByUpdate   = valueByUpdate;
        offer.numberOfUpdates = numberOfUpdates;       
        offer.offerMaker      = msg.sender;
        offer.trainer         = trainerAddr;        

        Log.Offer(offer);
        trainer.newOffer(offer);
    }

    function getPendingOffers() external view returns(DataTypes.Offer [] memory) {
        require(
            isTrainer(msg.sender), "Just registered trainners can check pending offer"
        );

        Trainer trainer = Trainer(trainers[msg.sender]);

        return trainer.getPendingOffers();        
    }

    function AcceptOffer(uint256 offerID) external {
        require(
            isTrainer(msg.sender), "Just registered trainners can accept an offer"
        );

        console.log("DAO: AcceptOffer:", offerID, msg.sender);

        Trainer trainer = Trainer(trainers[msg.sender]);

        DataTypes.Offer memory offer = trainer.acceptOffer(offerID);
        if (offer.offerMaker != address(0)) {
            Requester offerMaker = Requester(requesters[offer.offerMaker]);
            JobContract newContract = new JobContract(offer);

            trainer.newContract(newContract);
            offerMaker.newContract(newContract);

            //Insere no hash de Contractos
            jobContracts[address(newContract)] = newContract; 

            console.log("NewContract:", address(newContract),"OfferAccepted =",  offerID);
        }
    }

    function signJobContract(address addrContract) public payable {
        require(
            address(jobContracts[addrContract]) != address(0), "Job Contract not found"
            );

        JobContract job    = jobContracts[addrContract];
        console.log("signJobContract", msg.sender, msg.value);
        job.LogContract();

        bool bIsTrainer    = (msg.sender == job.trainerAddr());
        bool bIsOfferMaker = (msg.sender == job.offerMakerAddr());

        require(
            ((bIsTrainer) || (bIsOfferMaker)), "Just the trainer and the OfferMaker can assign the contract"
        );

        if (bIsOfferMaker) {
            require(
                msg.value >= job.totalAmount(), "Should be sent the exactly value to be locked"
            );
            job.lockAmount(msg.value);
        }
        
        job.sign(msg.sender);
        job.LogContract();
    }
    
    function isTrainer(address trainer) internal view returns (bool){
        return (trainers[trainer] != address(0));
    }

    function isRequester(address requester) internal view returns (bool){
        return (requesters[requester] != address(0));
    }
}