function samples = decodeCgxPacket(packet)
    % This can be customized for different CGX devices
    
    channelCount=11; 
    samples=zeros([1,channelCount], 'double');
    
    for i=1:channelCount
        samples(i) = double(packet(i*3-1))*(2^24) ...
                   + double(packet(i*3))*(2^17) ...
                   + double(packet(i*3+1))*(2^10);
    end
    
end

