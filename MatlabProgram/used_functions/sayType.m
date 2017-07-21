function sayType(nameReco, connection)
%SAYTYPE says orally the recognize type of trajectory.
%TODO verif ça fonctionne!

    sentence = ['"say" ', nameReco]
    connection.ispeak.clear();
    connection.ispeak.fromString(sentence);
    connection.ispeak.fromString(sentence);
    connection.port2.write(connection.ispeak);
end
