public class ProdCatUpsert implements Queueable, Database.AllowsCallouts {
    
    public Integer Index;
    public Final String Data;
    
    public ProdCatUpsert(Integer iIndex, String iData) {
        Index = iIndex;
        Data = iData;
    }
    
    public void execute(QueueableContext context) {
        
        ZObj.FetchCatalog Catalog = (ZObj.FetchCatalog)JSON.deserialize(
            Data, ZObj.FetchCatalog.class
        );
        ZObj.FetchCatalog Holder = new ZObj.FetchCatalog();
        Holder.products = new List<ZObj.FetchCatalogProducts>{Catalog.products[Index]};
        ZuoraSyncController.UpsertCatalog(Holder);
        Index++;
        if (Catalog.products.size() > Index) System.enqueueJob(new ProdCatUpsert(Index, Data));
        
    }
}