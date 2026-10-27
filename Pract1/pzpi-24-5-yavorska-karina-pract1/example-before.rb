def CalcPrice(u,items)
    if u!=nil
        t=0
        for i in items do t+=i.price end
        if u.is_vip then t=t*0.8 end
        return t
    end
end
