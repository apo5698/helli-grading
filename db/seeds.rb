u = User.create_or_find_by(name: 'Dingdong Yao', email: 'dyao3@ncsu.edu',
                           password: '123456', password_confirmation: '123456')
c = Course.create_or_find_by(name: 'CSC 116', term: 3, section: '004', user_id: u.id)
Assignment.create_or_find_by(name: 'Day 1', category: :exercise, course_id: c.id)
Assignment.create_or_find_by(name: 'Project 1', category: :project, course_id: c.id)
