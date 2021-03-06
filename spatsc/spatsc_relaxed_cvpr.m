function [ Z ] = spatsc_relaxed_cvpr( X, lambda_1, lambda_2, diagconstraint)

if (~exist('diagconstraint','var'))
    diagconstraint = 0;
end

max_iterations = 200;

func_vals = zeros(max_iterations,1);

[~, xn, ~] = size(X);

S = zeros(xn, xn); % S = Z
R = (triu(ones(xn,xn-1),1) - triu(ones(xn, xn-1))) + (triu(ones(xn, xn-1),-1)-triu(ones(xn, xn-1)));
R = sparse(R);

U = zeros(xn, xn-1);

G = zeros(xn, xn);
F = zeros(xn, xn-1); 

Z = zeros(xn, xn);

gamma_1 = 1;
gamma_2 = 1;
p = 1.1;

tol = 1*10^-3;

for k = 1 : max_iterations

    % Update Z
    V = S - (G/gamma_1);

    Z = solve_l1(V, lambda_1/gamma_1);

    % Set Z diag to 0
    if (diagconstraint)
        Z(logical(eye(size(Z)))) = 0;
    end

    % Update S
    A = X'*X + gamma_1*speye(xn,xn);
    B = gamma_2*(R*R');
    C = -(X'*X + gamma_2*U*R' + gamma_1*Z + G + F*R');

    S = lyap(A, B, C);

    % Update U
    V = S*R - (1/gamma_2)*F;

    U = solve_l1(V, lambda_2/gamma_2);

    % Update G, F

    G = G + gamma_1 * (Z - S);
    F = F + gamma_2 * (U - S*R);

    % Update gamma_1, gamma_2

    gamma_1 = p * gamma_1;
    gamma_2 = p * gamma_2;

    % Check convergence
    func_vals(iteration) = .5 * norm(X - X*Z,'fro')^2 + lambda_1*norm(Z,1) +lambda_2*norm(Z*R, 1);

    if iteration > 1
        if funVal(iteration) < tol
            break
        end
    end

    if iteration > 100
        if func_vals(iteration) < tol || func_vals(iteration-1) == func_vals(iteration) ...
                || func_vals(iteration-1) - func_vals(iteration) < tol
            break
        end
    end


end

end