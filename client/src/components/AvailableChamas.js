import React, { useState } from "react";
import { Badge, Container, ListGroup } from "react-bootstrap";

const AvailableChamas = () => {
  // Functionality if the list item is selected
  const selectItem = () => {
  };

  // The number of people in a group
  const [membersCount, setMembersCount] = useState(0);
  const [full, setFull] = useState(false);
  const [groupName, setGroupName] = useState(1);
  const [minGroupFee, setMinGroupFee] = useState(2)

  const isFull = () => {
    if (membersCount == 10) {
      setFull(true);
    }

  }
  return (
    <div>
      <Container className="mt-5" style={{ width: "60rem" }}>

        {/* We will create a new component where we will map through the list items */}
        <ListGroup as="ol" numbered>
          <ListGroup.Item
            action
            onClick={selectItem()}
            as="li"
            className="d-flex justify-content-between align-items-start"
          >
            <div className="ms-2 me-auto">
              <div className="fw-bold">Group {groupName}</div>
              This group is for a minimum of {minGroupFee} Eth
            </div>
            {!isFull ? (
              <Badge bg="danger" pill>
                full
              </Badge>
            ) : (
              <Badge bg="primary" pill>
                {membersCount}
              </Badge>
            )}
          </ListGroup.Item>


          {/* The code after line 47 will be deleted... only for demo purposes */}
          <ListGroup.Item
            action
            onClick={selectItem()}
            as="li"
            className="d-flex justify-content-between align-items-start"
          >
            <div className="ms-2 me-auto">
              <div className="fw-bold">Group {2}</div>
              This group is for a minimum of {3} Eth
            </div>
            {isFull ? (
              <Badge bg="danger" pill>
                full
              </Badge>
            ) : (
              <Badge bg="primary" pill>
                {membersCount}
              </Badge>
            )}
          </ListGroup.Item>
          <ListGroup.Item
            action
            onClick={selectItem()}
            as="li"
            className="d-flex justify-content-between align-items-start"
          >
            <div className="ms-2 me-auto">
              <div className="fw-bold">Group {3}</div>
              This group is for a minimum of {4} Eth
            </div>
            {!isFull ? (
              <Badge bg="danger" pill>
                full
              </Badge>
            ) : (
              <Badge bg="primary" pill>
                {membersCount}
              </Badge>
            )}
          </ListGroup.Item>
        </ListGroup>
      </Container>
    </div>
  );
};

export default AvailableChamas;
