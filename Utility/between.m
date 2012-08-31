function TF = between(a,b,check)
cp=@(u,v)u(:,1).*v(:,2)-u(:,2).*v(:,1);
TF = false;
if cp((b-a),(check-a)) == 0
    TF = min(a(2),b(2)) <= check(2);
    TF = TF && check(2) <= max(a(2),b(2));
    TF = TF && min(a(1),b(1)) <= check(1);
    TF = TF && check(1) <= max(a(1),b(1));
end
end