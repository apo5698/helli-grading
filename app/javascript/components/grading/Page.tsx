import * as React from 'react';

import { Button, Form } from 'react-bootstrap';

import Options from './Options';
import Table from './Table';

type Props = {
  type: string,
  gradeItemIds: Array<number>,
}

type State = {
  selectedGradeItemIds: Array<number>,
  options: object,
}

class Page extends React.Component<Props, State> {
  constructor(props) {
    super(props);

    this.state = {
      selectedGradeItemIds: props.gradeItemIds,
      options: {},
    };

    this.setSelectedGradeItemId = this.setSelectedGradeItemId.bind(this);
    this.setOptions = this.setOptions.bind(this);
    this.runSelected = this.runSelected.bind(this);
  }

  // Add the id to `selectedGradeItemIds` when checking, remove otherwise.
  setSelectedGradeItemId(id) {
    const { selectedGradeItemIds } = this.state;

    if (selectedGradeItemIds.includes(id)) {
      selectedGradeItemIds.splice(selectedGradeItemIds.indexOf(id), 1);
    } else {
      selectedGradeItemIds.push(id);
    }
  }

  setOptions(key: string, value: any) {
    const { options } = this.state;
    options[key] = value;
    this.setState({ options });
  }

  runSelected() {
    const {
      selectedGradeItemIds,
      options,
    } = this.state;
  }

  render() {
    const {
      type,
      gradeItemIds,
    } = this.props;

    const { options } = this.state;

    return (
      <>
        <Options type={type} setOptions={this.setOptions} />
        <Form.Group controlId="formBasicCheckbox">
          <Button
            variant="primary"
            type="button"
            onClick={() => { this.runSelected(); }}
          >
            Run selected
          </Button>
        </Form.Group>
        <Table
          gradeItemIds={gradeItemIds}
          setSelectedGradeItemId={this.setSelectedGradeItemId}
          options={options}
        />
      </>
    );
  }
}

export default Page;
