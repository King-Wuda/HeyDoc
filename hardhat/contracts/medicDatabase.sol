// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

error NotListed(address doctor);
error AlreadyListed(address doctor);
error NotOwner();
error NoProceeds();

contract MedicDatabase {
    struct Doctor {
        address doctor;
        string specialty;
        string degree;
        string university;
        uint256 experience;
        uint256 surgeries;
        bool active;
        bool verified;
    }

    event DoctorListed(
        address doctor,
        string degree,
        string university,
        string specialty,
        uint256 experience,
        uint256 surgeries,
        bool active,
        bool verfied
    );

    event DoctorCanceled(address doctor);

    event DoctorChanged(
        address doctor,
        string specialty,
        string degree,
        string university,
        uint256 experience,
        uint256 surgeries,
        bool active,
        bool verified
    );

    mapping(address => uint256) private s_proceeds;
    mapping(address => Doctor) private s_listings;

    modifier notListed(address doctor) {
        Doctor memory listing;
        if (listing.experience >= 0) {
            revert AlreadyListed(doctor);
        }
        _;
    }

    modifier isListed(address doctor) {
        Doctor memory listing;
        if (listing.experience < 0) {
            revert NotListed(doctor);
        }
        _;
    }

    modifier isOwner(address doctor) {
        if (msg.sender != doctor) {
            revert NotOwner();
        }
        _;
    }

    function listDoctor(
        address doctor,
        string memory specialty,
        string memory degree,
        string memory university,
        uint256 experience,
        uint256 surgeries,
        bool active,
        bool verified
    ) external notListed(doctor) {
        s_listings[msg.sender] = Doctor(
            msg.sender,
            specialty,
            degree,
            university,
            experience,
            surgeries,
            active,
            verified
        );
        emit DoctorListed(
            msg.sender,
            specialty,
            degree,
            university,
            experience,
            surgeries,
            active,
            verified
        );
    }

    function verifyDoctor(
        address doctor,
        string memory university,
        string memory degree
    ) public {
        require(doctor == msg.sender, "Not owner/doctor")
        Doctor memory listing = s_listings[msg.sender];
        listing.verified = true;
    }

    function buyConsultation(
        address patient,
        address doctor,
        uint256 price
    ) public payable {
        Doctor memory consultation = s_listings[doctor];
        s_proceeds[consultation.doctor] += msg.value;
    }

    function changeDoctor(
        address doctor,
        string memory specialty,
        string memory degree,
        string memory university,
        uint256 experience,
        uint256 surgeries,
        bool active,
        bool verified
    ) external isListed(msg.sender) isOwner(msg.sender) {
        // change doctor listing and restore data from Ipfs
        s_listings[msg.sender] = Doctor(
            msg.sender,
            specialty,
            degree,
            university,
            experience,
            surgeries,
            active,
            verified
        );
        emit DoctorChanged(
            msg.sender,
            specialty,
            degree,
            university,
            experience,
            surgeries,
            active,
            verified
        );
    }

    function cancelListing() external isListed(msg.sender) isOwner(msg.sender) {
        delete (s_listings[msg.sender]);
        emit DoctorCanceled(msg.sender);
    }

    function getListing() external view returns (Doctor memory) {
        return s_listings[msg.sender];
    }

    function withdrawProceeds()
        external
        isOwner(msg.sender)
        isListed(msg.sender)
    {
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) {
            revert NoProceeds();
        }
        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer failed");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
