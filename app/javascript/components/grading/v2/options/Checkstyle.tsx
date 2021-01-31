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
    <Form.Item name="rules" label="Checkstyle rules">
      <Checkbox.Group>
        {
          Object
            .entries(rules)
            .map(([name, description]) => (
              <Checkbox value={name} key={name} defaultChecked>
                <b>{name}</b>
                :&nbsp;
                {description}
              </Checkbox>
            ))
        }
      </Checkbox.Group>
    </Form.Item>
  );
};

export default Checkstyle;
