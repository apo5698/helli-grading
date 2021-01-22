import * as React from 'react';

import { Form } from 'react-bootstrap';

import Row from './Row';

type Props = {
  gradeItemIds: Array<number>,
  setSelectedGradeItemId: Function,
}

type State = {
  checkAll: boolean,
}

class Table extends React.Component<Props, State> {
  constructor(props) {
    super(props);

    this.state = {
      checkAll: true,
    };

    this.toggleCheckAll = this.toggleCheckAll.bind(this);
  }

  toggleCheckAll() {
    const { checkAll } = this.state;
    this.setState({ checkAll: !checkAll });
  }

  render() {
    const {
      gradeItemIds,
      setSelectedGradeItemId,
    } = this.props;
    const { checkAll } = this.state;

    return (
      <>
        <legend>Results</legend>
        <div className="table-responsive">
          <table className="table table-hover">
            <thead>
              <tr>
                <th scope="col">
                  <Form>
                    <Form.Check
                      type="checkbox"
                      checked={checkAll}
                      onChange={() => { this.toggleCheckAll(); }}
                    />
                  </Form>
                </th>
                <th scope="col">Participant</th>
                <th scope="col">Status</th>
                <th scope="col">Points</th>
                <th scope="col">Feedback</th>
                <th scope="col">Action</th>
                <th scope="col" />
              </tr>
            </thead>
            <tbody>
              {
                gradeItemIds.map((id) => (
                  <Row
                    id={id}
                    key={id}
                    setSelectedGradeItemId={setSelectedGradeItemId}
                  />
                ))
              }
            </tbody>
          </table>
        </div>
      </>
    );
  }
}

export default Table;
