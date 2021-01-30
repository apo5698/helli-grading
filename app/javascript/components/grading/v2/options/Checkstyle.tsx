import * as React from 'react';
import { useEffect, useState } from 'react';
import { Checkbox, Form } from 'antd';
import { getHelliApi } from '../../../HelliApiUtil';

const Checkstyle = () => {
  const [rules, setRules] = useState({});

  useEffect(() => {
    getHelliApi('checkstyle')
      .then((data) => setRules(data));
  }, []);

  return (
    <Form.Item name="checkstyle-rules" label="Checkstyle rules">
      {
        Object
          .entries(rules)
          .map(([name, description]) => (
            <Checkbox key={name}>
              <b>{name}</b>
              :&nbsp;
              {description}
            </Checkbox>
          ))
      }
    </Form.Item>
  );
};

export default Checkstyle;
