import * as React from 'react';
import { useEffect, useState } from 'react';

import { Checkbox, Form, Input, Spin } from 'antd';
import { getDependencies } from '../../../HelliApiUtil';

interface Dependency {
  name: string
  version: string,
  source: string,
  executable: string,
  checksum: string,
}

const Compile = () => {
  const [dependencies, setDependencies] = useState<Dependency[]>(null);

  useEffect(() => {
    getDependencies()
      .then((data: Dependency[]) => {
        setDependencies(data);
      });
  }, []);

  return (
    <>
      <Form.Item name="libraries" label="Libraries">
        <Checkbox.Group>
          {
            dependencies
              ? dependencies.map((dependency) => (
                <Checkbox value={dependency.name} key={dependency.name}>
                  {/* eslint-disable-next-line react/jsx-one-expression-per-line */}
                  {dependency.name} ({dependency.version}): {dependency.executable}
                </Checkbox>
              ))
              : <Spin />
          }
        </Checkbox.Group>
      </Form.Item>
      <Form.Item name="arguments" label="Arguments">
        <Input
          placeholder="Command line arguments"
          style={{ fontFamily: 'monospace' }}
          allowClear
        />
      </Form.Item>
    </>
  );
};

export default Compile;
