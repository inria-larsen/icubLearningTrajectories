function promp = LearningFacePosition(promp)
%LEARNINGFACEPOSITION learns orientation of the face according to the
%proMP.

% connection = initializeConnection;
% command = 'yarp connect /headPos/o /matlab/write';
% system(command);
% command = 'yarp connect /matlab/write /headPos/o';
% system(command);
% 
% for j=1:length(promp)
%     data_tot{j} = [];
% end
% 
% for i=1:5
%     for j=1:length(promp)
%         rep = input(['Keep looking at goal ', promp{j}.traj.label , ', and press a key.' ]);
%         for t=1:100
%             %ask data
%             connection.b.clear();
%             connection.b.addDouble(1.0);
%             connection.port.write(connection.b);
%             %retrieve data
%             connection.c.clear();
%             connection.port.read(connection.c);
%             data{j}{i}(t,:) = str2num(connection.c);
%         end
%         data_tot{j} = [data_tot{j} ; data{j}{i}];
%     end
% end
% 
% closeConnection(connection);
% 
% for j=1:length(promp)
% promp{j}.facePose.data = data_tot{j};
% promp{j}.facePose.mu = mean(data_tot{j}');
% promp{j}.facePose.cov = cov(data_tot{j}');
% end
load('testFace.mat');
drawFacePose(promp);

%Trouver moyen mettre poid en fonction critere



end