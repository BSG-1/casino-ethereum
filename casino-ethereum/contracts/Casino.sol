prggma solidity 0.4.20;

contract Casino {
    address public owner;
    uint256 public minimumBet;
    uint256 public totalBet;
    uint256 public numberOfBets;
    uint256 public maxAmountOfBets = 100;
    address[] public players;

    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }
    
    //The address of the player and => the user info 
    mapping(address => Player) public playerInfo;

    function() public payable {}


    //this is the constructor because it has the same name as that of the contract and we use it to set up the owner of that contract
    function Casino(uint256 _minimumBet) public {
        owner = msg.sender;
        if(_minimumBet != 0) minimumBet = _minimumBet
    }

    function kill() public {
        if(msg.sender == owner) selfdestruct(owner);
    }

    //makes sure that the player only plays once per game
    //the word constant indicates that this is a function that doesnt cost any gas to run because its returning an already existing value from the blockchain( important)
    function checkPlayerExists(address player) public constant returns(bool){
        for(uint256 i = 0; i < players.length; i++){
            if(players[i] == player) return true;
        }
        return false;
    }

    // To bet for a number between 1 and 10 both inclusive
    function bet(uint256 numberSelected) public payable {
      require(!checkPlayerExists(msg.sender));
      require(numberSelected >= 1 && numberSelected <= 10);
      require(msg.value >= minimumBet);

      playerInfo[msg.sender].amountBet = msg.value;
      playerInfo[msg.sender].numberSelected = numberSelected;
      numberOfBets++;
      players.push(msg.sender);
      totalBet += msg.value;
   }

   //Generates a number between 1 and 10 that will be the winner
   function generateNumberWinner() public {
       //takes the current block number and gets the last number + 1 so, for example, if the block number is 128142 the number generated will be 128142 % 10 = 2 and 2 +1 = 3.
       //this is not secure
       uint256 numberGenerated = block.number % 10 + 1; 
       //distribute the prizes for the winners
       distributePrizes(numberGenerated);
   }

    // Sends the corresponding ether to each winner depending on the total bets
    function distributePrizes(uint256 numberWinner) public {
      address[100] memory winners; // We have to create a temporary in memory array with fixed size
      uint256 count = 0; // This is the count for the array of winners
      for(uint256 i = 0; i < players.length; i++){
        address playerAddress = players[i];
        if(playerInfo[playerAddress].numberSelected == numberWinner){
            winners[count] = playerAddress;
            count++;
        }
        delete playerInfo[playerAddress]; // Delete all the players
      }
      players.length = 0; // Delete all the players array
      uint256 winnerEtherAmount = totalBet / winners.length; // How much each winner gets
      for(uint256 j = 0; j < count; j++){
        if(winners[j] != address(0)) // Check that the address in this fixed array is not empty
        winners[j].transfer(winnerEtherAmount);
      }
    }
}