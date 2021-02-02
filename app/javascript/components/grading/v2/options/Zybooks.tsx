import * as React from 'react';
import { useEffect, useState } from 'react';
import { Button, Form, Input, message, Space, Upload } from 'antd';
import { FormInstance } from 'antd/lib/form';
import { InboxOutlined, MinusCircleOutlined, PlusOutlined } from '@ant-design/icons';
import Papa from 'papaparse';
import { getHelliApi, HelliApiUrl } from '../../../HelliApiUtil';

const { Dragger } = Upload;

const Zybooks = (props: { form: FormInstance, assignmentId: number }) => {
  const { assignmentId } = props;
  const [fileList, updateFileList] = useState([]);
  const [defaultScale, setDefaultScale] = useState([]);

  const fileProps = {
    fileList,
    accept: 'text/csv',
    beforeUpload(file) {
      if (file.type !== 'text/csv') {
        message.error(`${file.name} is not a csv file.`);
        return false;
      }

      message.loading({ content: `Parsing ${file.name}...`, key: 'message' });

      const reader = new FileReader();
      reader.onload = (event) => {
        const str = event
          .target
          .result
          .toString()
          .replace(/Total \(\d+\)/, 'Total');

        const json = Papa
          .parse(str, { header: true, skipEmptyLines: true })
          .data
          .map((e) => ({ email: e['School email'], total: e.Total }));

        fetch(HelliApiUrl(`assignments/${assignmentId}/zybooks`), {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
          },
          body: JSON.stringify(json),
        })
          .then((response) => {
            if (!response.ok) {
              updateFileList([]);
              throw response;
            }
          })
          .then(() => {
            message.success({ content: `${file.name} uploaded.`, key: 'message' });
          })
          .catch((error) => {
            error
              .text()
              .then((text) => {
                message.error({ content: text, key: 'message' });
              });
          });
      };
      reader.readAsText(file);

      return false;
    },
  };

  useEffect(() => {
    getHelliApi('zybooks')
      .then((data) => {
        setDefaultScale(data);
      });
  }, []);

  useEffect(() => { props.form.resetFields(); }, [defaultScale]);

  return (
    <Space direction="vertical">
      <Dragger {...fileProps}>
        <p className="ant-upload-drag-icon">
          <InboxOutlined />
        </p>
        <p className="ant-upload-text">Click or drag file to this area to upload</p>
        <p className="ant-upload-hint">
          The filename should look like NCSUCSC116BalikSpring2021_report_004_2021-01-29_2359.csv
        </p>
      </Dragger>
      <Form.List name="scale" initialValue={defaultScale}>
        {
          (fields, { add, remove }) => (
            <>
              {
                fields.map((field) => (
                  <Space key={field.key} style={{ display: 'flex' }} align="baseline">
                    <Form.Item
                      {...field}
                      name={[field.name, 'total']}
                      fieldKey={[field.fieldKey, 'total']}
                      rules={[{ required: true, message: 'Missing total score' }]}
                    >
                      <Input placeholder="Total score >=" />
                    </Form.Item>
                    <Form.Item
                      {...field}
                      name={[field.name, 'point']}
                      fieldKey={[field.fieldKey, 'point']}
                      rules={[{ required: true, message: 'Missing point' }]}
                    >
                      <Input placeholder="Points" />
                    </Form.Item>
                    <MinusCircleOutlined onClick={() => remove(field.name)} />
                  </Space>
                ))
              }
              <Form.Item>
                <Button type="dashed" onClick={() => add()} block icon={<PlusOutlined />}>
                  Add scale
                </Button>
              </Form.Item>
            </>
          )
        }
      </Form.List>
    </Space>
  );
};

export default Zybooks;
