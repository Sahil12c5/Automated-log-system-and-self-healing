import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import java.sql.Connection;

public class TestDB {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl("jdbc:mysql://localhost:3306/autoheal_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC");
            config.setUsername("root");
            config.setPassword("");
            
            HikariDataSource ds = new HikariDataSource(config);
            Connection conn = ds.getConnection();
            System.out.println("Connection successful!");
            conn.close();
            ds.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
