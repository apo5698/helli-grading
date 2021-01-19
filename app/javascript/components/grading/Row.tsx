import * as React from 'react';
import { ReactElement } from 'react';

import { Button, Collapse, Form, OverlayTrigger, Spinner, Tooltip } from 'react-bootstrap';
import { ChevronDownIcon, ChevronUpIcon, CpuIcon } from '@primer/octicons-react';
import SyntaxHighlighter from 'react-syntax-highlighter';
import { tomorrow } from 'react-syntax-highlighter/dist/esm/styles/hljs';

import { getHelliApi, putHelliApi } from '../HelliApiUtil';
import Status from './Status';

type Props = {
  id: number,
  setSelectedGradeItemId: Function,
}

type State = {
  gradeItem: GradeItem,
  attachment: Attachment,
  checked: boolean,
  collapseOpen: boolean,
  collapseArrow: ReactElement,
  runButton: ReactElement,
}

type GradeItem = {
  id: number,
  participant: string,
  status: string,
  point: string,
  maximumPoints: string,
  feedback: string,
  stdout: string,
  stderr: string,
  exitstatus: number,
  error: number,
}

type Attachment = {
  id?: number,
  filename?: string,
  contentType?: string,
  byteSize?: number,
  checksum?: string,
  data: string,
}

class Row extends React.Component<Props, State> {
  static status = {
    inactive: 'Inactive',
    success: 'Success',
    resolved: 'Resolved',
    unresolved: 'Unresolved',
    error: 'Error',
    no_submission: 'No submission',
  };

  constructor(props) {
    super(props);

    this.state = {
      gradeItem: null,
      attachment: null,
      checked: true,
      collapseOpen: false,
      collapseArrow: <ChevronDownIcon />,
      runButton: <CpuIcon />,
    };

    this.toggleCheckbox = this.toggleCheckbox.bind(this);
    this.toggleCollapseOpen = this.toggleCollapseOpen.bind(this);
  }

  componentDidMount() {
    const { id } = this.props;

    getHelliApi(`grade_items/${id}`)
      .then((data) => {
        this.setState({ gradeItem: data });
      });

    getHelliApi(`grade_items/${id}/attachment`)
      .then((data) => {
        if (data) {
          this.setState({ attachment: data });
        }
      });
  }

  run() {
    this.setState({ runButton: <Spinner animation="border" size="sm" /> });

    const { id } = this.props;
    putHelliApi(`grade_items/${id}`)
      .then((data) => {
        this.setState({
          gradeItem: data,
          runButton: <CpuIcon />,
        });
      });
  }

  toggleCheckbox() {
    const { checked } = this.state;
    this.setState({ checked: !checked });

    const {
      id,
      setSelectedGradeItemId,
    } = this.props;
    setSelectedGradeItemId(id);
  }

  toggleCollapseOpen() {
    const { collapseOpen } = this.state;
    this.setState({ collapseOpen: !collapseOpen });
  }

  render() {
    const { id } = this.props;
    const {
      gradeItem,
      attachment,
      checked,
      collapseOpen,
      collapseArrow,
      runButton,
    } = this.state;

    return (
      <>
        <tr>
          {
            gradeItem
              ? (
                <>
                  <td>
                    <Form>
                      <Form.Check
                        type="checkbox"
                        id={id}
                        checked={checked}
                        onChange={() => { this.toggleCheckbox(); }}
                      />
                    </Form>
                  </td>
                  <th scope="row">
                    {gradeItem.participant}
                  </th>
                  <td>
                    <Status type={gradeItem.status}>
                      {Row.status[gradeItem.status]}
                    </Status>
                  </td>
                  <td>
                    <span className={
                      parseFloat(gradeItem.point) === parseFloat(gradeItem.maximumPoints)
                        ? 'text-success'
                        : 'text-danger'
                    }
                    >
                      {gradeItem.point}
                    </span>
                    /
                    {gradeItem.maximumPoints}
                  </td>
                  <td>
                    {gradeItem.feedback}
                  </td>
                  <td>
                    <OverlayTrigger
                      placement="top"
                      overlay={(
                        <Tooltip id={`tooltip-run-${gradeItem.participant}`}>
                          Run: &nbsp;
                          {gradeItem.participant}
                        </Tooltip>
                      )}
                    >
                      <Button
                        className="p-0"
                        variant="link"
                        size="sm"
                        type="button"
                        onClick={() => { this.run(); }}
                      >
                        {runButton}
                      </Button>
                    </OverlayTrigger>
                  </td>
                  <td onClick={() => { this.toggleCollapseOpen(); }}>
                    {collapseArrow}
                  </td>
                </>
              )
              : (
                <td colSpan={10}>
                  <Spinner animation="border" size="sm" />
                </td>
              )
          }
        </tr>
        <tr>
          <td colSpan={10} className="p-0">
            <Collapse
              in={collapseOpen}
              onEntered={() => { this.setState({ collapseArrow: <ChevronUpIcon /> }); }}
              onExited={() => { this.setState({ collapseArrow: <ChevronDownIcon /> }); }}
            >

              <div className="card-body">
                <div className="card">
                  {
                    attachment
                      ? (
                        <>
                          <div className="card-header">
                            {attachment.filename}
                          </div>
                          <div className="card-body">
                            <SyntaxHighlighter
                              language="java"
                              style={tomorrow}
                              showLineNumbers
                            >
                              {attachment.data}
                            </SyntaxHighlighter>
                          </div>
                        </>
                      )
                      : (
                        <div className="card-body">
                          Failed to locate attachment.
                        </div>
                      )
                  }
                </div>
              </div>
            </Collapse>
          </td>
        </tr>
      </>
    );
  }
}

export default Row;
