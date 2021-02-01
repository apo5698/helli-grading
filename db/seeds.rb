u1 = User.create_or_find_by(name: 'Dingdong Yao',
                            username: 'dyao3',
                            email: 'dyao3@ncsu.edu',
                            password: '12345678',
                            password_confirmation: '12345678',
                            role: :admin)
u1.skip_confirmation!
u1.save
c1 = Course.create_or_find_by(user_id: u1.id, name: 'CSC 116', section: '004')
Assignment.create_or_find_by(course_id: c1.id, name: 'Day 1', category: :exercise)
Assignment.create_or_find_by(course_id: c1.id, name: 'Project 1', category: :project)

u2 = User.create_or_find_by(name: 'Yulin Zhang',
                            username: 'yzhan114',
                            email: 'yzhan114@ncsu.edu',
                            password: '12345678',
                            password_confirmation: '12345678',
                            role: :admin)
u2.skip_confirmation!
u2.save
c2 = Course.create_or_find_by(user_id: u2.id, name: 'CSC 116', section: '002')
Assignment.create_or_find_by(course_id: c2.id, name: 'Day 1', category: :exercise)
Assignment.create_or_find_by(course_id: c2.id, name: 'Project 1', category: :project)
