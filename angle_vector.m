function angle = angle_vector(vector1, vector2)

DirVector1 = vector1(2,:) - vector1(1,:);
DirVector2 = vector2(2,:) - vector2(1,:);

angle = radtodeg(acos(dot(DirVector1,DirVector2)/norm(DirVector1)/norm(DirVector2)));
