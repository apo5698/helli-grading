import * as React from 'react';
import { useEffect, useState } from 'react';
import {
  Alert,
  Button,
  Card,
  Form,
  message,
  PageHeader,
  Popconfirm,
  Spin,
  Table,
  Tabs,
  Tag,
  Tooltip,
} from 'antd';
import { ReloadOutlined } from '@ant-design/icons';
import SyntaxHighlighter from 'react-syntax-highlighter';
import { tomorrow } from 'react-syntax-highlighter/dist/esm/styles/hljs';
import { deleteHelliApi, getHelliApi, putHelliApi } from '../../HelliApiUtil';

import 'antd/dist/antd.css';
import Compile from './options/Compile';
import Execute from './options/Execute';
import Checkstyle from './options/Checkstyle';

interface RubricItem {
  id: number,
  type: string,
  filename: string,
}

interface GradeItem {
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

interface Attachment {
  id: number,
  filename: string,
  contentType: string,
  byteSize: number,
  checksum: string,
  data: string,
}

const optionComponents = {
  Compile,
  Execute,
  Checkstyle,
};

function nameSorter(a: string, b: string): number {
  const nameA = a.split(' ');
  const nameB = b.split(' ');
  return nameA[1].localeCompare(nameB[1]) || nameA[0].localeCompare(nameB[0]);
}

function numberSorter(a: number | string, b: number | string): number {
  return parseInt(a.toString(), 10) - parseInt(b.toString(), 10);
}

const statusTagColors = {
  Success: 'success',
  Resolved: 'processing',
  Unresolved: 'warning',
  Error: 'error',
};

const columns: any = [
  {
    title: 'Participant',
    dataIndex: 'participant',
    fixed: 'left',
    sorter: (a: GradeItem, b: GradeItem) => nameSorter(a.participant, b.participant),
  },
  {
    title: 'Status',
    dataIndex: 'status',
    render: (status: string) => (
      <Tag color={statusTagColors[status] || 'default'} key={status}>
        {status}
      </Tag>
    ),
  },
  {
    title: 'Point',
    dataIndex: 'point',
    sorter: (a: GradeItem, b: GradeItem) => numberSorter(a.point, b.point),
  },
  {
    title: 'Action',
    dataIndex: 'action',
    fixed: 'right',
    width: 100,
    render: () => (
      <Tooltip title="Rerun">
        <Button shape="circle" icon={<ReloadOutlined />} />
      </Tooltip>
    ),
  },
];

const Page = (props: { rubricItemIds: number[] }) => {
  const { rubricItemIds } = props;

  const [currentRubricItemId, setCurrentRubricItemId] = useState<number>(rubricItemIds[0]);
  const [rubricItem, setRubricItem] = useState<RubricItem>({
    id: null,
    type: null,
    filename: null,
  });
  const [rubricItems, setRubricItems] = useState<RubricItem[]>([]);
  const [gradeItems, setGradeItems] = useState<GradeItem[]>([]);
  const [attachments, setAttachments] = useState<Attachment[]>([]);

  const [loading, setLoading] = useState(true);
  const [resetting, setResetting] = useState(false);
  const [resetPopconfirmVisible, setResetPopconfirmVisible] = useState(false);
  const [noSelectionWarning, setNoSelectionWarning] = useState(null);
  const [selectedRowKeys, setSelectedRowKeys] = useState([]);

  const [form] = Form.useForm();
  const { TabPane } = Tabs;
  const Options = optionComponents[rubricItem.type] || Spin;

  const fetchGradeItems = () => {
    setLoading(true);

    getHelliApi(`rubrics/items/${currentRubricItemId}/grade_items`)
      .then((data) => {
        setGradeItems(data);
        setLoading(false);
      });
  };

  useEffect(() => {
    getHelliApi(`rubrics/items/${currentRubricItemId}`)
      .then((data) => setRubricItem(data));
    fetchGradeItems();
  }, [currentRubricItemId]);

  useEffect(() => {
    const arr = [];
    rubricItemIds.forEach((i) => {
      getHelliApi(`rubrics/items/${i}`)
        .then((data) => arr.push(data));
    });
    setRubricItems(arr);
  }, []);

  const run = async (options) => {
    if (!selectedRowKeys.length) {
      setNoSelectionWarning(
        <Alert
          message="Select at least one grade item to run."
          type="error"
          style={{ marginBottom: '24px' }}
        />,
      );
      return;
    }

    const key = 'running';
    message.loading({ content: `Running 0 of ${selectedRowKeys.length}`, key, duration: 0 });

    setNoSelectionWarning(null);
    setLoading(true);

    // eslint-disable-next-line no-restricted-syntax
    for (let i = 0; i < selectedRowKeys.length; i += 1) {
      const gid = selectedRowKeys[i];
      // eslint-disable-next-line no-await-in-loop
      await putHelliApi(`grade_items/${gid}`, options);
      message.loading({ content: `Running ${i} of ${selectedRowKeys.length}`, key, duration: 0 });
    }

    message.success({ content: 'Done!', key, duration: 2 });
    fetchGradeItems();
  };

  const clear = () => {
    setResetting(true);
    setLoading(true);

    deleteHelliApi(`rubrics/items/${currentRubricItemId}/grade_items`)
      .then(() => {
        fetchGradeItems();
        setResetPopconfirmVisible(false);
        setResetting(false);
      });
  };

  const downloadAttachment = (record: GradeItem) => {
    if (attachments[record.id]) {
      return;
    }

    getHelliApi(`grade_items/${record.id}/attachment`)
      .then((attachment) => {
        attachments[record.id] = attachment;
        setAttachments((prevAttachments) => ({ ...prevAttachments, ...attachments }));
      });
  };

  const renderExpanded = (record: GradeItem) => {
    const attachment: Attachment = attachments[record.id];

    return (
      <Card type="inner" title={attachment?.filename} loading={attachment === undefined}>
        {
          attachment === null
            ? <span>Cannot load attachment.</span>
            : (
              <SyntaxHighlighter
                language="java"
                style={tomorrow}
                codeTagProps={{ style: { fontSize: '12px' } }}
                showLineNumbers
              >
                {attachment?.data}
              </SyntaxHighlighter>
            )
        }

      </Card>
    );
  };

  const renderPassRate = () => {
    if (!gradeItems.length) {
      return null;
    }

    let successCount = 0;

    gradeItems.forEach(({ status }) => {
      if (status === 'Success' || status === 'Resolved') {
        successCount += 1;
      }
    });

    return (
      <>
        <Table.Summary.Row>
          <Table.Summary.Cell index={0} colSpan={3}>Pass rate</Table.Summary.Cell>
          <Table.Summary.Cell index={0} colSpan={3}>
            {((successCount / gradeItems.length) * 100).toFixed(2)}
            %
          </Table.Summary.Cell>
        </Table.Summary.Row>
      </>
    );
  };

  const renderAveragePoints = () => {
    if (!gradeItems.length) {
      return null;
    }

    let average = 0;

    gradeItems.forEach(({ point }) => {
      average += parseInt(point, 10);
    });

    average /= gradeItems.length;

    return (
      <>
        <Table.Summary.Row>
          <Table.Summary.Cell index={0} colSpan={4}>Average</Table.Summary.Cell>
          <Table.Summary.Cell index={0} colSpan={2}>
            {average.toFixed(2)}
          </Table.Summary.Cell>
        </Table.Summary.Row>
      </>
    );
  };

  return (
    <PageHeader
      className="site-page-header"
      title="Automated Grading"
      subTitle={rubricItem.type}
      extra={[
        <Popconfirm
          title="Are you sure to reset grade items on this page?"
          visible={resetPopconfirmVisible}
          onConfirm={clear}
          onCancel={() => { setResetPopconfirmVisible(false); }}
          okText="Yes"
          cancelText="No"
          okButtonProps={{ loading: resetting }}
          key="clear"
        >
          <Button onClick={() => { setResetPopconfirmVisible(true); }}>Reset</Button>
        </Popconfirm>,
        <Button type="primary" htmlType="submit" onClick={() => { form.submit(); }} key="reset">
          Run selected
        </Button>,
      ]}
    >
      <Tabs
        defaultActiveKey={currentRubricItemId.toString()}
        onTabClick={(key) => {
          setTimeout(() => {
            setCurrentRubricItemId(parseInt(key, 10));
          }, 300);
        }}
      >
        {
          rubricItems
            .sort((a, b) => (a.id - b.id))
            .map((i) => (
              <TabPane tab={`${i.type} (${i.filename})`} key={i.id.toString()} />
            ))
        }
      </Tabs>
      <Form
        form={form}
        wrapperCol={{ span: 16 }}
        layout="horizontal"
        onFinish={(value) => {
          // noinspection JSIgnoredPromiseFromCall
          run(value);
        }}
      >
        <Options />
        {noSelectionWarning}
        <Table
          columns={columns}
          rowKey={(record: GradeItem) => record.id}
          dataSource={gradeItems}
          pagination={false}
          loading={loading}
          size="middle"
          rowSelection={{
            selectedRowKeys,
            onChange: setSelectedRowKeys,
          }}
          expandable={{
            expandedRowRender: (record) => renderExpanded(record),
            onExpand: (expanded, record) => { downloadAttachment(record); },
          }}
          summary={() => (
            <>
              {renderPassRate()}
              {renderAveragePoints()}
            </>
          )}
        />
      </Form>
    </PageHeader>

  );
};

export default Page;
