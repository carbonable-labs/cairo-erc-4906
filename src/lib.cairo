pub mod erc4906_component;
pub mod presets {
    pub mod erc4906_preset;
}

#[cfg(test)]
mod tests {
    mod utils;
    mod units {
        mod test_initialization;
        mod test_metadata_update;
    }
}
