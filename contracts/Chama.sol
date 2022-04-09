// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

/**
 * @title Chama
 * @dev Blockchain Chama System
 * This simplifies the implementation of "Women Chamas ".
 */

contract Chama {
    // Chama Managers will be required to create chamas and will be responsible for disbursing dividends for emergency and loans
    // To be a chama Manager you'll have to a minimum of 3eth
    address public chamaManager1;
    address public chamaManager2;
    address public chamaManager3;
    address public chamaManager4;
    // Since I'm storing members in a mapping I need membersCount to keep track of the number of members
    uint256 public membersCount;
    uint256 public loanCount;
    uint256 public chamaCount;
    uint256 public requestCount;
    uint256 public approversCount;
    uint256 public memberFundCount;
    uint256 public loanRequestCount;
    uint256 public membersToApproveCount = 1;

    struct Member {
        uint256 memberID;
        address payable member;
        uint256 chamaID;
        uint256 registrationDate;
        bool isActive;
        bool hasLoaned;
        bool hasEmergency;
        bool hasBeenPaid;
    }

    // keeps track of the members of a specific chama
    mapping(uint256 => address) public membersToChama;
    // keeps track of the numbers of members of a specific chama
    mapping(address => uint256) chamaMembersCount;
    // membApproved is used to keep track of the members who have approved a loan request so that a member doesn't approve more than once
    mapping(address => bool) membHasAlreadyApproved;
    // memberPaidStatus is meant to keep track the payment status of chama members
    mapping(address => bool) memberPaidStatus;

    Member[] public members;

    struct ChamaDetails {
        uint256 chamaID;
        string _name;
        address chamaManager;
        uint256 registrationFee;
        uint256 premium;
        uint256 target;
        uint256 creationDate;
        // disbusrement period will be the amount of time it take before funds are disbursed i.e 1 month or a week
        uint256 disbursementPeriod;
        address[] chamaMembers;
        uint256 endDate;
    }

    // store details about request for loan or emergencyLoan
    struct Request {
        uint256 requestID;
        string description;
        uint256 amount;
        address payable recipient;
        uint256 chamaID;
        uint256 memberNo;
        bool complete;
        uint256 approvalCount;
    }
    struct Loan {
        uint256 loanID;
        uint256 memberID;
        uint256 chamaID;
        address loaneeAddress;
        uint256 amount;
        uint256 dayAwarded;
        uint256 dueDate;
        bool hasBeenPaid;
    }

    Request[] public requests;
    Loan[] public loans;
    // mapping will include chama members who need to approve
    mapping(uint256 => address) public approversToChama1;
    mapping(uint256 => address) public approversToChama2;
    mapping(uint256 => address) public approversToChama3;
    mapping(uint256 => address) public approversToChama4;
    //mapping(address => bool) public approvers;

    //mapping(uint256 => ChamaDetails) chamas;
    ChamaDetails[] public chamas;

    event NewLoanRequest(
        uint256 approvCount,
        string descr,
        uint256 amt,
        address loanee,
        uint256 membID,
        bool status
    );

    event NewChama(
        uint256 chamaCount,
        string name,
        address chamAddress,
        uint256 regFee,
        uint256 premium,
        uint256 target,
        uint256 date,
        uint256 _reemittancePeriod,
        address[] chamMembers,
        uint256 chamsEndDate
    );

    // The address that deploys this contract will be chamaManager1
    // Constructor
    /** constructor(
        string _nam,
        string _registrationFee,
        string _premium,
        string _target,
        uint256 _reemittancePeriod
    ) public {
        chamaCount++;
        chamaManager1 = msg.sender;
        uint256 time = block.timestamp;
        address[] memory membs;
        // 4896000 is Epoch Unix time equivalence of a year
        chamas[chamaCount] = ChamaDetails(
            chamaCount,
            _nam,
            chamaManager1,
            _registrationFee,
            _premium,
            _target,
            time,
            _reemittancePeriod,
            membs,
            4896000
        );
        //return(chamaCount);
    } */

    // function to create a Chama

    function createRandomChama(
        string memory _name,
        uint256 registrationFee,
        uint256 premium,
        uint256 target,
        uint256 _reemittancePeriod
    ) public payable returns (uint256, address) {
        // For one to be a chama Manager he or she must be willing to pay 3 ether
        require(msg.value >= 3 ether);
        require(
            chamaManager1 == address(0) ||
                chamaManager2 == address(0) ||
                chamaManager3 == address(0) ||
                chamaManager4 == address(0)
        );
        // chamaAdd will be the Chama Address which will be equal to ChamaManager's address
        address chamaAdd;
        uint256 date;
        // chamaManager address will be the
        if (
            chamaManager1 == address(0) ||
            chamaManager2 == address(0) ||
            chamaManager3 == address(0) ||
            chamaManager4 == address(0)
        ) {
            chamaManager1 = msg.sender;
            chamaAdd = chamaManager1;
        } else if (
            chamaManager2 == address(0) ||
            chamaManager3 == address(0) ||
            chamaManager4 == address(0)
        ) {
            // assign to chamaManager2
            chamaManager2 = msg.sender;
            chamaAdd = chamaManager2;
        } else if (chamaManager3 == address(0) || chamaManager4 == address(0)) {
            // assign to chamaManager3
            chamaManager3 = msg.sender;
            chamaAdd = chamaManager3;
        } else if (chamaManager4 == address(0)) {
            // assign to chamaManager4
            chamaManager4 = msg.sender;
            chamaAdd = chamaManager4;
        } else {
            // stop creating a random chama
            revert("Stop creating the chama!");
        }
        chamaCount++;
        date = block.timestamp;
        address[] memory mbrs;
        uint256 endingDate = 4896000;
        chamas[chamaCount] = ChamaDetails(
            chamaCount,
            _name,
            chamaAdd,
            registrationFee,
            premium,
            target,
            date,
            _reemittancePeriod,
            mbrs,
            endingDate
        );

        emit NewChama(
            chamaCount,
            _name,
            chamaAdd,
            registrationFee,
            premium,
            target,
            date,
            _reemittancePeriod,
            mbrs,
            endingDate
        );

        return (chamaCount, chamaAdd);
    }

    // chamaAddress will be the address of the chama's manager
    // in the front end application we'll have a list of available chamas with the addresses of their respective managers
    // function to join Chama
    function joinChama(address chamaAddre, uint256 chamaCt)
        public
        payable
        returns (uint256)
    {
        require(
            chamaAddre == chamaManager1 ||
                chamaAddre == chamaManager2 ||
                chamaAddre == chamaManager3 ||
                chamaAddre == chamaManager4
        );
        require(chamaMembersCount[chamaAddre] <= 12);
        require(msg.value >= chamas[chamaCt].registrationFee);
        uint256 registrationTime = block.timestamp;
        membersCount++;
        // membersCount will serve as memberID
        members.push(
            Member(
                membersCount,
                msg.sender,
                chamaCt,
                registrationTime,
                true,
                false,
                false,
                false
            )
        );
        membersToChama[chamaCt] = chamaAddre;
        //chamaMembersCount[chamaAddre] = chamaMembersCount[chamaAddre].add(1);
        chamaMembersCount[chamaAddre] = membersCount;
        chamas[chamaCt].chamaMembers.push(msg.sender);
        return (chamaCt);
    }

    /** function listOfChamaDetails(uint256 _chamsID) public view returns(ChamaDetails[]) {
        // expect to return the members addresses made with the loan requests details
        return (chamas[_chamsID]);
    }  */

    // function to disburse
    // Using useEffect will keep on calling this function to keep track of time and make sure it
    function disburseDividends(uint256 _chamID, address _membReceiving) public {
        require(block.timestamp >= chamas[_chamID].creationDate + 408000);
        require(memberPaidStatus[_membReceiving] == false);
        memberFundCount++;
        members[memberFundCount].member.transfer(
            (chamas[_chamID].chamaManager.balance * 50) / 100
        );
        chamas[_chamID].creationDate = block.timestamp;
        members[memberFundCount].hasBeenPaid = true;
        memberPaidStatus[_membReceiving] = true;
        if (memberFundCount > 12) {
            memberFundCount = 0;
        }
        // send and transfer are only available for objects of type "address payable", not "address"
    }

    // function to check subscription status
    function checkSubscriptionStatus(uint256 _membersCount)
        public
        view
        returns (bool)
    {
        // Epoch Unix time equivalence of 30 days
        // I converted 30 days to Epoch Unix time equivalence i.e 408000
        //require(members[_membersCount].hasPaid == false )
        //require(block.timestamp == members[_membersCount].registrationDate + 408000);
        // Need to add logic to check if he or she has paid
        //require(renewSubscription(_membersCount) == false);
        bool expired;
        if (
            block.timestamp == members[_membersCount].registrationDate + 408000
        ) {
            expired = true;
            return (expired);
        } else {
            expired = false;
            return (expired);
        }
    }

    // function to renew Subscription
    function renewSubscription(uint256 _membersCount) public payable {
        require(checkSubscriptionStatus(_membersCount) == false);
        uint256 chama = members[_membersCount].chamaID;
        require(msg.value >= chamas[chama].premium);
        members[_membersCount].registrationDate = block.timestamp;
        members[_membersCount].isActive = true;
    }

    // decisions as to whether to award loans to members will be based on a consensus made by every chama member
    // function to create a Loan request
    function createLoanRequest(
        string memory _description,
        uint256 _amount,
        uint256 _memberNo,
        uint256 _chmID
    ) public {
        address payable recipient = msg.sender;
        uint256 approvalCount;
        bool requestStatus = false;
        loanRequestCount++;
        requests.push(
            Request(
                loanRequestCount,
                _description,
                _amount,
                recipient,
                _chmID,
                _memberNo,
                requestStatus,
                approvalCount
            )
        );
        for (uint256 i = 0; i < chamas[_chmID].chamaMembers.length; i++) {
            if (_chmID == 1) {
                approversToChama1[membersToApproveCount] = chamas[_chmID]
                    .chamaMembers[i];
                membersToApproveCount++;
            } else if (_chmID == 2) {
                approversToChama2[membersToApproveCount] = chamas[_chmID]
                    .chamaMembers[i];
                membersToApproveCount++;
            } else if (_chmID == 3) {
                approversToChama3[membersToApproveCount] = chamas[_chmID]
                    .chamaMembers[i];
                membersToApproveCount++;
            } else if (_chmID == 4) {
                approversToChama4[membersToApproveCount] = chamas[_chmID]
                    .chamaMembers[i];
                membersToApproveCount++;
            } else {
                revert("Chama with that ID does not exist!");
            }
        }
        emit NewLoanRequest(
            approvalCount,
            _description,
            _amount,
            recipient,
            _memberNo,
            requestStatus
        );
    }

    // function returns a list of loan requests
    function listOfLoanRequests() internal view returns (Request[] memory) {
        // expect to return the several requests made with the loan requests details
        return (requests);
    }

    // function that Chama members will call to approve loan requests
    function approveLoanRequest(
        uint256 _requestID,
        uint256 _approverID,
        uint256 _chamsId
    ) public {
        //uint256 loaneeNumber = requests[_requestID].memberNo;
        //require(members[loaneeNumber].chamaID)
        if (_chamsId == 1) {
            require(approversToChama1[_approverID] == msg.sender);
        } else if (_chamsId == 2) {
            require(approversToChama2[_approverID] == msg.sender);
        } else if (_chamsId == 3) {
            require(approversToChama3[_approverID] == msg.sender);
        } else if (_chamsId == 4) {
            require(approversToChama4[_approverID] == msg.sender);
        }
        // there may be many loan requests someone may argue
        // but at the moment our rule is we can only administer one loan at a time
        require(!membHasAlreadyApproved[msg.sender]);
        requests[_requestID].approvalCount++;
        membHasAlreadyApproved[msg.sender] = true;
    }

    // function to award loan based on consensus arrived by every member
    // useEffect hook which is dispatched whenever there is change in state
    // At the moment the contract process a Chama at a time, can't process concurrent requests
    function awardLoanRequest(uint256 _requestID) public {
        // In order to award loan, decision is influenced by chama members
        uint256 memId = requests[_requestID].memberNo;
        require(members[memId].isActive);
        require(requests[_requestID].approvalCount >= 6);
        require(!requests[_requestID].complete);
        //chamas[chamaID].chamaManager.transfer()
        requests[_requestID].recipient.transfer(
            ((chamas[requests[_requestID].chamaID].chamaManager.balance * 5) /
                100)
        );
        requests[_requestID].complete = true;
        uint256 timeAwarded = block.timestamp;
        uint256 loanDueDate = timeAwarded + 408000;
        address manager = chamas[requests[_requestID].chamaID].chamaManager;
        address loaneeAdd = members[memId].member;
        loanCount++;
        loans[loanCount] = Loan(
            loanCount,
            memId,
            requests[_requestID].chamaID,
            loaneeAdd,
            (manager.balance * 5) / 100,
            timeAwarded,
            loanDueDate,
            false
        );
        members[memId].hasLoaned = true;
        // I want to set the membHasAlreadyApproved mapping with address as its key and value as a boolean field to the default mapping value
        //delete membHasAlreadyApproved;
    }
    // Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable

    function payLoanAwarded(uint256 _loanId) public payable returns(bool) {
        require(!loans[_loanId].hasBeenPaid);
        uint256 dueTime = loans[_loanId].dueDate;
        uint256 blockTime = block.timestamp;
        uint256 loanPayAmt = loans[_loanId].amount;
        uint256 loanAmt;
        uint256 mbID = loans[_loanId].memberID;
        bool paid;
        // If you don't pay within the two months time frame your account is inactivated
        if (blockTime <= dueTime) {
            require(msg.value >= loanPayAmt);
            paid = loans[_loanId].hasBeenPaid;
            paid = true;
        } else if (blockTime > dueTime) {
            if (blockTime >= dueTime + 408000) {
                loanAmt = (loanPayAmt * 102) / 100;
                require(msg.value >= loanAmt);
                paid = loans[_loanId].hasBeenPaid;
                paid = true;
            } else if (blockTime >= dueTime + 816000) {
                loanAmt = (loanPayAmt * 104) / 100;
                require(msg.value >= loanAmt);
                paid = loans[_loanId].hasBeenPaid;
                paid = true;
            } else {
                members[mbID].isActive = false;
                paid = loans[_loanId].hasBeenPaid;
                paid = true;
            }
        }
        return paid;
    }
    

    // Chama ends at the indicated date, once you join the Chama you can't leave until the end date reaches
    function endChama() public {
        // give one day for dividends to be sent to the last person and then they get dividends then the group is deleted
        for (uint256 i = 1; i <= chamaCount; i++) {
            if (block.timestamp >= chamas[i].endDate + 86400) {
                delete chamas[i];
            }
        }
    }
}
