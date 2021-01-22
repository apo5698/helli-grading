import * as React from 'react';
import { ReactElement } from 'react';

import { Col, Form, Spinner } from 'react-bootstrap';

import { getDependencies } from '../../../HelliApiUtil';

type Props = {
  setOptions: Function,
}

type State = {
  dependencies: Array<Dependency>,
  selectedDependencies: object
}

type Dependency = {
  name: string | ReactElement
  version?: string,
  source?: string,
  executable?: string,
  checksum?: string,
}

class Compile extends React.Component<Props, State> {
  constructor(props) {
    super(props);

    this.state = {
      dependencies: null,
      selectedDependencies: null,
    };
  }

  componentDidMount() {
    const { selectedDependencies } = this.state;
    selectedDependencies = {};

    getDependencies()
      .then((data: Array<Dependency>) => {
        this.setState({ dependencies: data }, () => {

          data.forEach((dep) => {
            selectedDependencies[dep.name.toString()] = false;
          });
          this.setState({ selectedDependencies });
        });
      });
  }

  toggleSelected(name) {
    const { selectedDependencies } = this.state;
    selectedDependencies[name] = !selectedDependencies[name];
    this.setState({ selectedDependencies });
  }

  render() {
    const { setOptions } = this.props;
    const {
      dependencies,
      selectedDependencies,
    } = this.state;

    return (
      <>
        <Form.Group controlId="libraries">
          <Form.Label>Libraries</Form.Label>
          {
            Object.keys(selectedDependencies).length > 0
              ? Object.entries(selectedDependencies)
                // eslint-disable-next-line no-unused-vars
                .map((dependency, _) => (
                  <Form.Check
                    type="checkbox"
                    id={dependency[0]}
                    label={dependency[0]}
                    key={dependency[0]}
                    selected={dependency[1]}
                    onChange={this.toggleSelected(dependency[0])}
                  />
                ))
              : <div><Spinner animation="border" size="sm" /></div>
          }
        </Form.Group>
        <Form.Row>
          <Col sm="auto">
            <Form.Group controlId="arguments">
              <Form.Label>Command Line Arguments</Form.Label>
              <Form.Control type="text" placeholder="-Xlint:none -Xmx256m" />
              <Form.Text className="text-muted">
                Separated by spaces.
              </Form.Text>
            </Form.Group>
          </Col>
        </Form.Row>
      </>
    );
  }
}

export default Compile;
