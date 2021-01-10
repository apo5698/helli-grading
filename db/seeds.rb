u1 = User.create_or_find_by(name: 'Dingdong Yao',
                            username: 'dyao3',
                            email: 'dyao3@ncsu.edu',
                            password: '12345678',
                            password_confirmation: '12345678',
                            role: :admin)
u1.skip_confirmation!
u1.save
c = Course.create_or_find_by(name: 'CSC 116', term: 3, section: '004', user_id: u1.id)
Assignment.create_or_find_by(name: 'Day 1', category: :exercise, course_id: c.id)
Assignment.create_or_find_by(name: 'Project 1', category: :project, course_id: c.id)

u2 = User.create_or_find_by(name: 'Yulin Zhang',
                            username: 'yzhan114',
                            email: 'yzhan114@ncsu.edu',
                            password: '12345678',
                            password_confirmation: '12345678',
                            role: :admin)
u2.skip_confirmation!
u2.save
c = Course.create_or_find_by(name: 'CSC 116', term: 3, section: '002', user_id: u2.id)
Assignment.create_or_find_by(name: 'Day 1', category: :exercise, course_id: c.id)
Assignment.create_or_find_by(name: 'Project 1', category: :project, course_id: c.id)
