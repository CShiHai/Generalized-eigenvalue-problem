function [CV,lvec,Vcell, Vonly] = POIcv(Bn1, An1, Bn2,An2, k, option, inputstruct)
% POICV Penalized Orthogonal Iteration to solve GEV with cross-validation
% POICV惩罚正交迭代求解具有交叉验证的GEV
% [CV,lvec,Vcell] = POIcv(Bn1, An1, Bn2,An2, k, option)
% [CV,lvec,Vcell] = POIcv(Bn1, An1, [],[], k, option)
% [CV,lvec,Vcell] = POIcv(Bn1, An1, Bn2,An2, k, option, inputstruct)
%
% input:
%  Bn1, An1: p-by-p training matrices   训练矩阵
%  Bn2, An2: p-by-p testing matrices    测试矩阵
%           (if empty, then POICV just returns lvec and Vcell)
%  k: dimension of subspace (number of eigenvectors)
%  option =  POI-L, POI-C, FastPOI-L, or FastPOI-C;
%   A = Penalized Orthogonal Iteration with coefficient-wise L1 penalty (lasso)
%   C = Penalized Orthogonal Iteration with coordinate-wise L1 penalty (group lasso)
%   Da= Fast POI with coefficient-wise L1 penalty (lasso)
%   D =  Fast POI with coordinate-wise L1 penalty (group lasso)
%
% inputstruct: a struct consisting of
%   nGrid: number of grid points for evaluation of CV (default = 11);CV评估的网格点数量
%   maxIterInner: maximum number of iteration for cyclic descent (= ell)循环下降的最大迭代次数
%              (default = 100)
%   lvec : vector of tuning parameters调谐参数矢量
%
% output
%  CV: Cross-validation score (the larger, the better)交叉验证分数
%  lvec: vector of tuning parameters调谐参数矢量
%  Vcell: Cell array of "Q", computed for each value of tuning parameters  针对每个调谐参数值计算的“Q”单元阵列
%  Vonly (debug purpose only)
%
% See also POI, POIlim, POIv
%
% Last updated May 2018
% Sungkyu Jung



option = 'POIcv-C';
% initialization
ll = 11;
maxIterInner = 1000;

if nargin > 6
    if isfield(inputstruct,'nGrid') 
        ll = inputstruct.nGrid;
    end
    if isfield(inputstruct,'maxIterInner') 
        maxIterInner = inputstruct.maxIterInner;
    end
    if isfield(inputstruct,'lvec') 
        lvec = inputstruct.lvec;
        ll = length(lvec);
    end
end

if isempty(Bn2)
    CVflag = false;
else
    CVflag = true;
end

if strcmp(option,'POIcv-L'); option = 'A';end
if strcmp(option,'POIcv-C'); option = 'C';end
if strcmp(option,'FastPOIcv-L'); option = 'Da';end
if strcmp(option,'FastPOIcv-C'); option = 'D';end

if ~exist('lvec','var')
    switch option
        case 'A'
            lmaxCvec = POIlim(An1,'A',1);
            lmax = lmaxCvec(1);
        case 'C'
            lmaxCvec = POIlim(An1,'C',k);
            lmax = lmaxCvec(1);
        case 'Da' % 'D' or 'Da'
            lmaxD = POIlim(An1,'Da', k);
            lmax = lmaxD(1);
        case 'D' % 'D' or 'Da'
            lmaxD = POIlim(An1,'D', k);
            lmax = lmaxD(1);
    end
    
    
    
    % Added ON 9/11/2017
    % 
    % lmax = lmax * 2/3;
    
    
    lvec = (0.75.^(ll-1:-1:0) .* lmax);
end
CV= zeros(ll,1);
Vcell = cell(ll,1);


if CVflag
    
    if double(option(1)) < double('D') % if option == A or C, then use the warm starts
        [Q0] = POI(Bn1, An1, 0, k, option, maxIterInner);
        for il = 1:ll
            [Q] = POI(Bn1, An1, lvec(il), k, option, maxIterInner,Q0);
            [v] = POIv(Bn1, An1, Q);
            Vcell{il} = v;
            if norm(Q)==0
                CV(il) = 0;
            else
                CV(il) = trace( ( v.U' * An2 *v.U ) / ( v.U' * Bn2 *v.U) );
            end
            Q0 = Q;
        end
        
    else  % if option == D or Da then initial value not needed.
        for il = 1:ll
            [Q] = POI(Bn1, An1, lvec(il), k, option, maxIterInner);
            [v] = POIv(Bn1, An1, Q);
            Vcell{il} = v;
            if norm(Q)==0
                CV(il) = 0;
            else
                CV(il) = trace( ( v.U' * An2 *v.U ) / ( v.U' * Bn2 *v.U) );
            end
        end
    end
    
    
else
    
    
    if double(option(1)) < double('D') % if option == A or C, then use the warm starts
        [Q0] = POI(Bn1, An1, 0, k, option, maxIterInner);
        for il = 1:ll
            [Q] = POI(Bn1, An1, lvec(il), k, option, maxIterInner,Q0);
            [v] = POIv(Bn1, An1, Q);
            Vcell{il} = v;
            Q0 = Q;
        end
        
    else  % if option == D or Da then initial value not needed.
        for il = 1:ll
            [Q] = POI(Bn1, An1, lvec(il), k, option, maxIterInner);
            [v] = POIv(Bn1, An1, Q);
            Vcell{il} = v;
        end
    end
    
end

if nargout > 3
    Vonly = cell(ll,1);
    for i = 1:ll
        Vonly{i} = Vcell{i}.Q;
    end
end

