function [ jnmcc, n, jnmcct, jnmccsfl, jnmccsflcorr ] = D_LFPCORR_BASIC( jnm, win, sfl )

if size(jnm, 3) > 1
   
    jnm_t = [];
    for i = 1 : size(jnm, 3)
        jnm_t = cat(2, jnm_t, jnm(:,:,i));
    end
    jnm_t(:,isnan(jnm_t(1,:))) = [];
    jnm = jnm_t; clear jnm_t
end

nChan = size( jnm, 1 );
nWin = floor( length( jnm ) / win );
Wins = floor( size( jnm,2 ) / win );
nWin = randi(Wins, 1, nWin);
if sfl > 0
    nSfl = nWin;
else
    nSfl  = sfl;
end


for i = 1 : nChan
    for j = 1 : nChan
        if isnan( jnm( i, 1 ) ) || isnan( jnm( j, 1 ) )
            
            jnmcc( i , j ) = NaN;
            jnmcct( i, j ) = NaN;
            jnmccsfl( i, j ) = NaN;
            
            continue
            
        end
        
        for k = 1:size(nWin,2)
            
            itWin = ( win * nWin(k) - ( win-1 ) ) : ( win * nWin(k) );
            
            tempCCv = corrcoef( jnm( i, itWin ), ...
                jnm( j, itWin ) );
            tempCC( k ) = tempCCv( 2, 1 );
            
        end
        
        if sfl ~= 0
            for l = 1:size(nSfl,2)
                
                rWin1 = randi( nWin(l) );
                rWin2 = randi( nWin(l) );
                
                itWin1 = ( win * rWin1 - ( win-1 ) ) : ( win * rWin1 );
                itWin2 = ( win * rWin2 - ( win-1 ) ) : ( win * rWin2 );
                
                tempCCsflv = corrcoef( jnm( i, itWin1 ), ...
                    jnm( j, itWin2 ) );
                tempCCsfl( l ) = tempCCsflv( 2, 1 );
                
            end
        end
        
        jnmcc( i, j ) = mean( tempCC );
        jnmccmean = mean( tempCC );
        jnmccstd = std( tempCC );
        jnmcct( i, j ) = jnmccmean / jnmccstd;
        tempCC = [];
        tempCCv = [];
        jnmccstd = [];
        
        if sfl~=0
            jnmccsfl( i, j ) = mean( tempCCsfl );
            tempCCsfl = [];
            tempCCsflv = [];
        else
            jnmccsfl = 0;
        end
        
    end
end

if sfl~=0
    jnmccsflcorr = jnmcc - jnmccsfl;
else
    jnmccsflcorr = 0;
end
n = floor( length( jnm ) / win );

end

