function ptCloudWorld = getPointCloud2()
%GETPOINTCLOUD Summary of this function goes here
%   Detailed explanation goes here
    tftree = rostf; %finds TransformationTree directly from ros
    pointCloudSub = rossubscriber('/camera/depth/points');
    pause(1);
    camera_transf = getTransform(tftree, 'world', 'camera_depth_link');
    %camera_transf = getTransform(tftree, 'camera_link', 'world');
    pointcloud = receive(pointCloudSub);
    xyz = readXYZ(pointcloud); 
    camera_transl = camera_transf.Transform.Translation;
    camera_rotation = camera_transf.Transform.Rotation;
    camera_quaternion = [camera_rotation.W, camera_rotation.X,...
        camera_rotation.Y,camera_rotation.Z];
    camera_translation = [camera_transl.X,...
        camera_transl.Y,camera_transl.Z];
    quat = camera_quaternion;
    rotm = quat2rotm(quat);
    tform = rigidtform3d(rotm,camera_translation);

    % Remove NaNs
    xyzLess = double(rmmissing(xyz));
    % Create point cloud object
    ptCloud = pointCloud(xyzLess);
    % Transform point cloud to world frame
    ptCloudWorld = pctransform(ptCloud,tform);
end
