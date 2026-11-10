use once_cell::sync::Lazy;
use regex::Regex;

// DFA linear-time regex: O(n) sobre o tamanho da entrada, imune a ReDoS
static CPF_REGEX: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r"\b(\d{3})\.?(\d{3})\.?(\d{3})-?(\d{2})\b")
        .expect("Falha ao compilar regex de CPF")
});

static CNPJ_REGEX: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r"\b(\d{2})\.?(\d{3})\.?(\d{3})/?(\d{4})-?(\d{2})\b")
        .expect("Falha ao compilar regex de CNPJ")
});

/// Mascara CPFs preservando apenas os dígitos intermediários: ***.456.789-**
pub fn sanitize_cpf(input: &str) -> String {
    CPF_REGEX
        .replace_all(input, "***.$2.$3-**")
        .into_owned()
}

/// Mascara CNPJs preservando a raiz corporativa: **.XXX.XXX/****-**
pub fn sanitize_cnpj(input: &str) -> String {
    CNPJ_REGEX
        .replace_all(input, "**.***.$3/$4-**")
        .into_owned()
}

/// Sanitização combinada em passada única
pub fn sanitize_all_pii(input: &str) -> String {
    let intermediate = sanitize_cpf(input);
    sanitize_cnpj(&intermediate)
}

#[cfg(feature = "python")]
use pyo3::prelude::*;

#[cfg(feature = "python")]
#[pyfunction]
fn sanitize_text(text: &str) -> PyResult<String> {
    Ok(sanitize_all_pii(text))
}

#[cfg(feature = "python")]
#[pymodule]
fn pii_sanitizer(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(sanitize_text, m)?)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cpf_masking_with_punctuation() {
        let raw = "Contrato do titular com CPF 123.456.789-00 registrado.";
        let clean = sanitize_cpf(raw);
        assert_eq!(clean, "Contrato do titular com CPF ***.456.789-** registrado.");
    }

    #[test]
    fn test_cpf_masking_unpunctuated() {
        let raw = "Documento: 12345678900 verificado.";
        let clean = sanitize_cpf(raw);
        assert_eq!(clean, "Documento: ***.456.789-** verificado.");
    }

    #[test]
    fn test_cnpj_masking() {
        let raw = "Empresa Brassol CNPJ 12.345.678/0001-90 ativa.";
        let clean = sanitize_cnpj(raw);
        assert_eq!(clean, "Empresa Brassol CNPJ **.***.678/0001-** ativa.");
    }

    #[test]
    fn test_boundary_empty_string() {
        assert_eq!(sanitize_all_pii(""), "");
    }
}
