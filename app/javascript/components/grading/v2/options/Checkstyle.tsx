import * as React from 'react';
import { useEffect, useState } from 'react';
import { Checkbox, Form } from 'antd';
import { FormInstance } from 'antd/lib/form';
import { getHelliApi } from '../../../HelliApiUtil';

const Checkstyle = (props: { form: FormInstance }) => {
  const [config, setConfig] = useState([]);
  const [initialValue, setInitialValue] = useState([]);

  useEffect(() => {
    getHelliApi('checkstyle')
      .then((data) => {
        setInitialValue(Object.keys(data));

        const arr = [];
        Object
          .entries(data)
          .forEach(([name, description]) => {
            arr.push({ label: <span><b>{name}</b>: {description}</span>, value: name });
          });
        setConfig(arr);
      });
  }, []);

  useEffect(() => props.form.resetFields(), [initialValue]);

  return (
    <Form.Item name="config" label="Checkstyle Configurations" initialValue={initialValue}>
      <Checkbox.Group options={config} />
    </Form.Item>
  );
};

export default Checkstyle;
