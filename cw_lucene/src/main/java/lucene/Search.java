package lucene;

import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

import java.io.IOException;
import java.nio.file.Paths;

public class Search {
    private static final String INDEX_DIRECTORY = "lucene_index";

    public static void main(String[] args) throws IOException, ParseException {

        String querystr = "urodzić";
        Directory directory = FSDirectory.open(Paths.get(INDEX_DIRECTORY));
        PolishAnalyzer analyzer = new PolishAnalyzer();

        try (IndexReader reader = DirectoryReader.open(directory)) {
            IndexSearcher searcher = new IndexSearcher(reader);
            Query query = new QueryParser("title", analyzer).parse(querystr);

            int maxHits = 10;
            TopDocs docs = searcher.search(query, maxHits);
            ScoreDoc[] hits = docs.scoreDocs;

            System.out.println("Znaleziono " + hits.length + " pasujących dokumentów:");
            for (int i = 0; i < hits.length; ++i) {
                int docId = hits[i].doc;
                Document d = searcher.doc(docId);
                System.out.println((i + 1) + ". ISBN: " + d.get("isbn") + ", Tytuł: " + d.get("title"));
            }
        }
    }
}

